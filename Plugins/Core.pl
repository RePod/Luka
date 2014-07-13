addPlug('Core_Ignore', {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Core Ignore',
  'description' => "This plugin sets up a way to ignore problem users.",
  'dependencies' => ['Core_Utilities'],
  'code' => {
    'pre' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^PRIVMSG|NOTICE$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        my $network = $lk{data}{networks}[$lk{tmp}{connection}{fileno($irc{irc})}]{name};
        foreach $regex (@{$irc{data}{ignore}}){ if($irc{msg}[0] =~ /$regex/i) { return 0; } }
        return 1;
      }
      else { return 1; }
    }
  }
});
addPlug('Core_Command', {
  'creator' => 'Caaz',
  'version' => '1.1',
  'name' => 'Core Command',
  'dependencies' => ['Core_Utilities','Userbase','Fancify'],
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      lkDebug($irc{raw});
      if($irc{msg}[1] =~ /^PRIVMSG|NOTICE$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        my $network = $lk{data}{networks}[$lk{tmp}{connection}{fileno($irc{irc})}]{name};
        my $prefix = $lk{data}{prefix};
        if($parsed{where} =~ /^$parsed{nickname}$/i) { $prefix = $lk{data}{prefix}.'?'; }
        if($parsed{msg} =~ /^$prefix(.+)$/i) {
          my $com = $1;
          foreach $plugin (keys %{$lk{plugin}}) {
            foreach $regex (keys %{$lk{plugin}{$plugin}{commands}}) {
              if($com =~ /$regex/i) {
                my %command = %{$lk{plugin}{$plugin}{commands}{$regex}};
                if($command{cooldown}) {
                  if(($lk{tmp}{plugin}{'Core_Command'}{cooldown}{$parsed{username}}{$regex}) && ($lk{tmp}{plugin}{'Core_Command'}{cooldown}{$parsed{username}}{$regex} > time)) { return 1; }
                  else { $lk{tmp}{plugin}{'Core_Command'}{cooldown}{$parsed{username}}{$regex} = time + $lk{plugin}{$plugin}{commands}{$regex}{cooldown}; }
                }
                eval {
                  if($command{access}) {
                    my %account = %{$utility{'Userbase_info'}($network,$parsed{nickname})};
                    if(($account{access}) && ($account{access} >= $command{access})) {
                      &{$command{code}}($network,\%irc,\%parsed,$lk{data}{plugin}{$plugin},$lk{tmp}{plugin}{$plugin}) if($command{code});
                    }
                    else { &{$utility{'Fancify_say'}}($irc{irc},$parsed{where},"You don't have enough >>access for this command."); }
                  }
                  else { &{$command{code}}($network,\%irc,\%parsed,$lk{data}{plugin}{$plugin},$lk{tmp}{plugin}{$plugin}) if($command{code}); }
                };
                if($@) {
                  &{$utility{'Fancify_say'}}($irc{irc},$parsed{where},"Error [\x04$plugin\x04] $@");
                }
              }
            }
          }
        }
      }
    },
  }
});
addPlug('Core_CTCP', {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Core CTCP',
  'dependencies' => ['Core_Utilities'],
  'code' => {
    'irc' => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /^PRIVMSG$/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        if($parsed{msg} =~ /\x01(.+)\x01/i) {
          my $ctcp = $1;
          if($ctcp =~ /^VERSION$/i) { lkRaw($irc{irc},"NOTICE $parsed{nickname} :\x01VERSION $lk{version} ($lk{os})\x01"); }
          elsif($ctcp =~ /^TIME$/i) { lkRaw($irc{irc},"NOTICE $parsed{nickname} :\x01TIME ".localtime."\x01"); }
          elsif($ctcp =~ /^FINGER$/i) { lkRaw($irc{irc},"NOTICE $parsed{nickname} :\x01FINGER Oh god yes\x01"); }
          elsif($ctcp =~ /^PING$/i) { lkRaw($irc{irc},"NOTICE $parsed{nickname} :\x01PING PONG\x01"); }
        }
      }
    }
  }
});
addPlug('Core_Utilities',{
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Core Utilities',
  'code' => {
    'load' => sub {
      %utility = ();
      # Throw all utilities into %utilities!
      foreach $plugin (keys %{$lk{plugin}}) {
        foreach $utilityName (keys %{$lk{plugin}{$plugin}{utilities}}) {
          $utility{$plugin.'_'.$utilityName} = $lk{plugin}{$plugin}{utilities}{$utilityName};
        }
      }
      #&{$utility{'Core_Utilities_debugHash'}}(\%utility);
    }
  },
  'utilities' => {
    'uniq' => sub { my %seen; grep !$seen{$_}++, @_ }, # I can't take any credit for this, but it is fucking beautiful.
    'debugHash' => sub {
      # Input: \%hash;
      my %hash = %{ shift(); };
      lkDebug("DEBUG");
      my @keys = keys %hash; @keys = sort @keys;
      foreach(@keys) { lkDebug("$_ => $hash{$_}"); }
    },
    'parse' => sub {
      # Input: @Msg
      # Output: nickname, username, host, msg, where
      my %return;
      #Confs!~Confs@such.strange.wow : PRIVMSG : #yugibro : >read review
      ($return{nickname}, $return{username}, $return{host}) = split/\!|\@/, $_[0];
      if($_[2] =~ /^\#/) { $return{where} = $_[2]; }
      else { $return{where} = $return{nickname}; }
      ($return{msg} = $_[3]) =~ s/\003\d{1,2}(?:\,\d{1,2})?|\02|\017|\003|\x16|\x09|\x13|\x0f|\x15|\x1f//g;
      chomp($return{msg});
      return \%return;
    },
    'getHandle' => sub {
      # Get Handle from network name.
      # Input -> Network name
      foreach(keys %{$lk{tmp}{connection}}) {
        if($lk{data}{networks}[$lk{tmp}{connection}{$_}]{name} =~ /^$_[0]$/i) {
          return $lk{tmp}{filehandles}{$_};
        }
      }
      return 0;
    },
    'shuffle' => sub { my $deck = shift; return unless @$deck; my $i = @$deck; while (--$i) { my $j = int rand ($i+1); @$deck[$i,$j] = @$deck[$j,$i]; } }
  }
});