{ lib, pkgs, config, ... }@inputs:
let
  minio-dir = "/data/minio";
  minio-data = "${minio-dir}/data";
  minio-config = "${minio-dir}/config";
  minio-port = "9002";
  region = "ap-southeast-1";
  bucket = "nix-cache";
  user-name = "nix";

  upload-policy = pkgs.writeText "nix-cache-write.json" ''
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "UploadToCache",
          "Effect": "Allow",
          "Action": [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:ListMultipartUploadParts",
            "s3:PutObject"
          ],
          "Resource": [
            "arn:aws:s3:::${bucket}",
            "arn:aws:s3:::${bucket}/*"
          ]
        }
      ]
    }
  '';

  read-policy = pkgs.writeText "nix-cache-read.json" ''
    {
      "Id": "DirectReads",
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "AllowDirectReads",
              "Action": [
                  "s3:GetObject",
                  "s3:GetBucketLocation"
              ],
              "Effect": "Allow",
              "Resource": [
                  "arn:aws:s3:::${bucket}",
                  "arn:aws:s3:::${bucket}/*"
              ],
              "Principal": "*"
          }
      ]
    }
  '';

  none-policy = pkgs.writeText "none-policy.json" ''
    {
      "Version": "2012-10-17",
      "Statement": [{
          "Sid": "DenyAll",
          "Effect": "Deny",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::${bucket}/*",
          "Principal": "*"
      }]
    }
  '';

  host-config = ''
    ignore_invalid_headers off;
    client_max_body_size 0;
    proxy_buffering off;
  '';

  location-config = ''
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_connect_timeout 300;
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    chunked_transfer_encoding off;
  '';
in lib.internal.simpleModule inputs "minio" {
  services.nginx.virtualHosts = {
    "binarycache.home.monoid.al" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = host-config;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${minio-port}";
        extraConfig = location-config;
      };
    };
  };

  users.users.minio = {
    group = "minio";
    uid = config.ids.uids.minio;
  };
  users.groups.minio.gid = config.ids.uids.minio;

  systemd.tmpfiles.rules = [
    "d '${minio-config}' - minio minio - -"
    "d '${minio-data}' - minio minio - -"
  ];

  systemd.services.minio = {
    enable = true;
    path = [ pkgs.minio pkgs.coreutils pkgs.bash pkgs.curl ];
    after = [ "network-online.target" "local-fs.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "minio";
      Group = "minio";
      LimitNOFILE = 65536;
      ExecStartPost = ''${pkgs.coreutils}/bin/timeout 30 sh -c 'while ! curl --silent --fail http://localhost:${minio-port}/minio/health/cluster; do sleep 1; done' '';
    };
    script = ''
      set -e
      export MINIO_REGION=${region}
      export MINIO_BROWSER=off
      export MINIO_ROOT_USER=$(<"${minio-dir}/keys/minio-access-key")
      export MINIO_ROOT_PASSWORD=$(<"${minio-dir}/keys/minio-secret-key")
      minio server --address localhost:${minio-port} --config-dir "${minio-config}" "${minio-data}"
    '';
  };

  systemd.services.minio-config = {
    enable = true;
    path = [ pkgs.minio pkgs.minio-client ];
    requiredBy = [ "multi-user.target" ];
    after = [ "minio.service" ];
    serviceConfig = {
      Type = "simple";
      User = "minio";
      Group = "minio";
      RuntimeDirectory = "minio-config";
    };
    script = ''
      set -e
      export MINIO_ROOT_USER=$(<"${minio-dir}/keys/minio-access-key")
      export MINIO_ROOT_PASSWORD=$(<"${minio-dir}/keys/minio-secret-key")
      CLIENT_ACCESS_KEY=${user-name}
      CLIENT_SECRET_KEY=$(<"${minio-dir}/keys/${user-name}-secret-key")
      CONFIG_DIR=$RUNTIME_DIRECTORY
      mc --config-dir "$CONFIG_DIR" config host add minio http://localhost:${minio-port} "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"
      mc --config-dir "$CONFIG_DIR" admin user add minio "$CLIENT_ACCESS_KEY" "$CLIENT_SECRET_KEY"
      mc --config-dir "$CONFIG_DIR" mb --ignore-existing minio/${bucket}
      mc --config-dir "$CONFIG_DIR" anonymous set-json ${none-policy} minio/${bucket}
      mc --config-dir "$CONFIG_DIR" anonymous set none minio/${bucket}
      mc --config-dir "$CONFIG_DIR" admin policy detach minio POLICY --user="$CLIENT_ACCESS_KEY"
      mc --config-dir "$CONFIG_DIR" admin policy create minio POLICY "${upload-policy}"
      mc --config-dir "$CONFIG_DIR" admin policy attach minio POLICY --user="$CLIENT_ACCESS_KEY"
      mc --config-dir "$CONFIG_DIR" anonymous set-json "${read-policy}" minio/${bucket}
      mc --config-dir "$CONFIG_DIR" anonymous get minio/${bucket}
      mc --config-dir "$CONFIG_DIR" anonymous get-json minio/${bucket}
    '';
  };
}
