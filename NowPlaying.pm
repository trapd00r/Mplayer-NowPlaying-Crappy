package Mplayer::NowPlaying;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(np stream_np $np_log);

use strict;
use Carp;
use Data::Dumper;

our $np_log;
$np_log = undef;

sub stream_np {
  croak("\$np_log is undefined!") unless(defined($np_log));
  open(my $fh, '<', $np_log) or croak("Can not open $np_log for reading: $!");
  my @content = <$fh>;
  close($fh);

  my %stream_vars = ();

  for my $line(@content) {
    if($line =~ /ICY Info: StreamTitle='(.+)';St.+/) {
      #$current_title = $1;
      $stream_vars{title} = $1;
    }
    #else {
    #  $stream_vars{title} = '';
    #}
    if($line =~ m/^(Name|Genre|Website|Public|Bitrate)\s*:\s(.+)$/g) {
      $stream_vars{lc($1)} = $2; # Name, Radio Schizoid...
    }
  }
  return \%stream_vars;
}


sub np {
  my $wanted = shift;
  croak("\$np_log is undefined!") unless(defined($np_log));

  open(my $fh, '<', $np_log) or croak("Can not open $np_log for reading");
  my @content = <$fh>;
  close($fh);

  my %information = (); # metadata and info
  
  my %mapped_vars = ( # mplayer internal hash keys is the key here
    ID_CLIP_INFO_VALUE0 => 'title',
    ID_CLIP_INFO_VALUE1 => 'artist',
    ID_CLIP_INFO_VALUE2 => 'album',
    ID_CLIP_INFO_VALUE3 => 'year',
    ID_CLIP_INFO_VALUE4 => 'comment',
    ID_CLIP_INFO_VALUE5 => 'genre',
    ID_AUDIO_BITRATE    => 'bitrate',
    ID_AUDIO_CODEC      => 'codec',
    ID_AUDIO_FORMAT     => 'format',
    ID_AUDIO_ID         => 'id',
    ID_AUDIO_NCH        => 'channels',
    ID_AUDIO_RATE       => 'chapters',
    ID_DEMUXER          => 'demuxer',
    ID_LENGTH           => 'length',
    ID_SEEKABLE         => 'seekable', # 1,0
    ID_START_TIME       => 'start',
    ID_FILENAME         => 'file',
  );

  my %shname_vars = reverse(%mapped_vars);

  foreach my $var(@content) {
    if($var =~ m/\b(\w+)=(.+)\b/g) {
      $information{$1} = $2; # ID_CLIP_INFO_VALUE1, Nightwish
    }
  }
  $wanted = $shname_vars{$wanted}; # get ID_...
  chomp($information{$wanted});
  return $information{$wanted};    # return 'Nightwish' ...
}

=pod

=head1 NAME

Mplayer::NowPlaying - Query metadata information from a running Mplayer process

=head1 SYNOPSIS

  use Mplayer::NowPlaying qw($np_log np stream_np);

  $np_log = './mplay.log';

  my $artist = np('artist');
  my $album  = np('album');
  my $title  = np('title');

  printf("%s - %s (%s)\n", $artist, $title, $album);


  my $stream_info = stream_np();
  my $title       = $stream_info->{title};
  my $website     = $stream_info->{website};

  printf("%s from %s\n", $title, $website);

=head1 DESCRIPTION

B<Mplayer> does not provide a API, the next best thing is to use it's ability to
read commands from files and/or named pipes.

B<Mplayer::NowPlaying> makes retrieval of metadata from such a process a little
bit easier.

B<Mplayer::NowPlaying> exports two functions, np() for local data and
stream_np() for streaming data.


  my $bitrate     = np('bitrate');        # 128000
  my $stream_info = stream_np();          # returns a hash reference
  my $stream_name = $stream_info->{name}; 

You have to set the logfile to use. B<$np_log> is globally exported, so you can do:

  $np_log = "$ENV{HOME}/.mplayer/mplayer.log";

Valid arguments for the np() function are as follows:

  title
  artist
  album
  year
  comment
  track
  genre
  bitrate
  codec
  format
  id
  channels
  chapters
  demuxer
  length
  seekable
  start
  file

Valid keys for the hash reference provided by stream_np() are:

  name
  genre
  website
  public
  bitrate

=head1 ENVIRONMENT

You might want to consider aliasing mplayer, since it needs the -identify
switch.

  alias mplayer="mplayer -identify $@> $HOME/.mplayer/mylog.log"


=head1 AUTHOR

Written by Magnus Woldrich.

=head1 REPORTING BUGS

Report bugs to trapd00r@trapd00r.se

Mplayer::NowPlaying home page: <http://github.com/trapd00r/Mplayer-NowPlaying/>

=head1 COPYRIGHT

Copyright 2010 Magnus Woldrich. License GPLv2: GNU GPL version 2 or later
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

=head1 SEE ALSO

B<Radio Playing Daemon> <http://github.com/trapd00r/RPD/>

=cut

1;
