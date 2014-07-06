addPlug('Log', {
  name => 'Logging',
  description => "This plugin will store logs into ./Logs/Network/Channel.txt",
  creator => 'Caaz',
  version => '1',
  utilities => {
    'write' => sub {
      #Input : Network, Channel, What
      # ./Logs/Network/Channel.txt
      # localtime() <nickname> What
      my $channel = $_[1];
      $channel =~ s/^\#//g;
      $channel =~ s/\W/_/g;
      foreach('./Logs/', "./Logs/$_[0]/") { if (!-e $_) { mkdir($_); } }
      open FILE, ">>./Logs/$_[0]/\#$channel.txt";
      print FILE localtime()."\t$_[2]\n";
      close FILE;
    }
  },
  code => {
    irc => sub {
      my %irc = %{$_[0]};
      if($irc{msg}[1] =~ /PRIVMSG|NOTICE/i) {
        my %parsed = %{&{$lk{plugin}{'Core_Utilities'}{utilities}{parse}}(@{$irc{msg}})};
        my $network = $irc{name};
        &{$utility{'Log_write'}}($irc{name},$parsed{where},"<$parsed{nickname}>\t$parsed{msg}");
      }
      #Caaz!Caaz@I.am.Caazy.you.see:PART:#testopia
      #Caaz!Caaz@I.am.Caazy.you.see:JOIN:#testopia
      elsif($irc{msg}[1] =~ /PART|JOIN/) {
        &{$utility{'Log_write'}}($irc{name},$irc{msg}[2],"$irc{msg}[1]\t$irc{msg}[0]");
      }
      else {
        lkDebug(join ':', @{$irc{msg}});
      }
    }
  }
});