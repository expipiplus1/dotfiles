use strict;
use warnings;
use English '-no_match_vars';
use Irssi;

our $VERSION = '1.0.0';
our %IRSSI = (
	authors     => 'Paul Backus',
	contact     => 'snarwin@gmail.com',
	name        => 'emotional',
	description => 'Provides shortcuts for unicode emotes',
	license     => 'MIT',
	url         => 'https://raw.githubusercontent.com/pbackus/irssi-emotional/master/emotional.pl',
);

my %emotes = (
	'check'    => '☑',
	'dongers'  => 'ヽ༼ຈل͜ຈ༽ﾉ',
	'flip'     => '(╯°□°）╯︵ ┻━┻',
	'flower'   => '(✿◠‿◠)',
	'give'     => '༼ つ ◕_◕ ༽つ',
	'guns'     => '(☞ﾟ∀ﾟ)☞',
	'lenny'    => '( ͡° ͜ʖ ͡°)',
	'look'     => 'ಠ_ಠ',
	'nocheck'  => '☐',
	'notes'    => '♫',
	'roll'     => '◔_◔',
	'shades'   => '(-■_■)',
	'shrug'    => '¯\_(ツ)_/¯',
	'shrugs'   => '¯\_(ツ)_/¯',
	'tears'    => 'ಥ_ಥ',
	'thumbsup' => '👍',
	'tickle'   => '(ԅ ͡° ͜ʖ ͡°)ԅ',
	'unflip'   => '┬─┬ノ( º _ ºノ)',
);

sub render_emotes {
	my ($text, $server, $win_item) = @_;

	my ($name, $offset, $length);

	while ($text =~ /:(\w+):/g) {
		$name = $1;
		$offset = $LAST_MATCH_START[0];
		$length = $LAST_MATCH_END[0] - $offset;

		if (exists $emotes{$name}) {
			substr($text, $offset, $length) = $emotes{$name};
		}
	}

	Irssi::signal_continue($text, $server, $win_item);
}

Irssi::signal_add('send text', \&render_emotes);
Irssi::signal_add('command me', \&render_emotes);
