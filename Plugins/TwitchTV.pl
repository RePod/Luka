addPlug("TwitchTV",{
  'creator' => 'RePod',
  'version' => '1',
  'name' => 'TwitchTV Status',
  'dependencies' => ['Fancify','Core_Utilities'],
  'modules' => ['LWP::Simple'],
  'description' => "Display information about TwitchTV streams either manually by name or automatically by URL.",
  'utilities' => {
<<<<<<< HEAD
    'twitchify' => sub {
      # input: name, return: status
      # TODO: JSON maybe? Work out better variable management.
      ($twitch_title,$twitch_stream_type,$twitch_channel_count,$twitch_status,$twitch_meta_game) = ($_[0],"?","?","?","?");
      my @temp = split(/\n/, get("http://api.justin.tv/api/stream/list.xml?channel=$twitch_title"));
      @keep = [];
      foreach (@temp) {
        my $r = /\<(\w+)\>(.+?)\<\/(\w+)\>/;
        my $s = "twitch_".$1;
        if (${$s}) {
          push @keep, $s;
          ${$s} = $2;
        }
      }
      my $s = "";
      if ($twitch_stream_type ne "?") {
        $s = "[\x04$twitch_channel_count\x04] $twitch_status [\x04$twitch_meta_game\x04] [http://twitch.tv/$twitch_title]";
      } else {
        $s = "\x04$twitch_title\x04 is offline. [\x04According to the API\x04] [http://twitch.tv/$twitch_title]";
      }
      foreach (@keep) { undef ${"$_"}; } undef @keep;
      return $s;
    }
  },
  'commands' => {
    '^Twitch (\w+)$' => {
      'tags' => ['media'],
      'description' => "Display information about TwitchTV streams manually.",
      'example' => "twitch twitch",
      'code' => sub {
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},&{$utility{'TwitchTV_twitchify'}}("$1"));		
=======
    'info' => sub {
      # Input: FileHandle, Where, Twitch User
      # Output: Boolean (streaming/notstreaming)
      my $user = $_[2];
      my $json = get('http://api.justin.tv/api/stream/list.json?channel='.$user);
      $json =~ s/^\[|\]$//g;
      my %twitch;
      eval { %twitch = %{decode_json($json)}; };
      if($@) { &{$utility{'Fancify_say'}}($_[0],$_[1],">>$user is offline. [\x04According to the API\x04] [http://twitch.tv/$user]"); return 0; }
      else {
        &{$utility{'Fancify_say'}}($_[0],$_[1],"[>>$twitch{channel_count}] $twitch{title} [\x04$twitch{meta_game}\x04] [http://twitch.tv/$user]");
        return 1;
      }
    },
  },
  'commands' => {
    '^Twitch (\w+)$' => {
      'tags' => ['media', 'utility'],
      'description' => "Display information about TwitchTV streams manually.",
      'example' => "twitch twitch",
      'code' => sub {
        &{$utility{'TwitchTV_info'}}($_[1]{irc},$_[2]{where},$1);	
>>>>>>> upstream/master
      }
    },
  },
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^PRIVMSG|NOTICE$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
<<<<<<< HEAD
        if($parsed{msg} =~ /twitch\.tv\/\w+/i) {
         foreach($parsed{msg} =~ /twitch\.tv\/(\w+)/g) {
            &{$utility{'Fancify_say'}}($irc{irc},$parsed{where},&{$utility{'TwitchTV_twitchify'}}("$1"));
          }
=======
        foreach($parsed{msg} =~ /twitch\.tv\/(\w+)/g) {
          &{$utility{'TwitchTV_info'}}($irc{irc},$parsed{where},$_);
>>>>>>> upstream/master
        }
      }
    }
  }
});