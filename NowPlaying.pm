package Mplayer::NowPlaying;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(np $np_log);

use strict;
use Carp;

our $np_log;
$np_log = undef;

sub np {
  my $wanted = shift;
  croak('$np_log is undefined!') unless defined($np_log);

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
    ID_CLIP_INFO_VALUE5 => 'track', # track #
    ID_CLIP_INFO_VALUE6 => 'genre',
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
    if($var =~ m/(\w+)=([\w-]+)/) {
      $information{$1} = $2; # ID_CLIP_INFO_VALUE1, Nightwish
    }
  }
  $wanted = $shname_vars{$wanted}; # get ID_...
  return $information{$wanted};    # return 'Nightwish' ...
}

=pod

=head1 NAME

Mplayer::NowPlaying - Query metadata information from a running Mplayer process

=head1 SYNOPSIS

  use strict;
  use Mplayer::NowPlaying qw($np_log np);

  $np_log = './mplay.log';

  my $artist = np('artist');
  my $album  = np('album');
  my $title  = np('title');

  printf("%s - %s (%s)\n", $artist, $title, $album);

=head1 DESCRIPTION

Mplayer does not provide an API, the next best thing is to use the -slave option
together with the ability to control it using a named pipe. 

Mplayer::NowPlaying exports one function, np(), that takes a single argument,
the metadata tag to return:

  my $bitrate = np('bitrate'); # 128000

You have to set the logfile to use. $np_log is globally exported, so you can do:

  $np_log = "$ENV{HOME}/.mplayer/mplayer.log";

Valid arguments for the np() function is:

  ID_CLIP_INFO_VALUE0
  ID_CLIP_INFO_VALUE1
  ID_CLIP_INFO_VALUE2
  ID_CLIP_INFO_VALUE3
  ID_CLIP_INFO_VALUE4
  ID_CLIP_INFO_VALUE5
  ID_CLIP_INFO_VALUE6
  ID_AUDIO_BITRATE
  ID_AUDIO_CODEC     
  ID_AUDIO_FORMAT    
  ID_AUDIO_ID        
  ID_AUDIO_NCH       
  ID_AUDIO_RATE      
  ID_DEMUXER         
  ID_LENGTH          
  ID_SEEKABLE        
  ID_START_TIME       
  ID_FILENAME         

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

Radio Playing Daemon <http://github.com/trapd00r/RPD/>
=cut

1;
