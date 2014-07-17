addPlug("Fancify", {
  'creator' => 'Caaz',
  'version' => '3.1',
  'name' => 'Fancify',
  'dependencies' => ['Core_Command'],
  'commands' => {
    '^GlobalFancy (\d{1,2},\s*\d{1,2})$' => {
      'description' => "Changes Fancify colors.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub {
        my @colors = split /\,\s*/, $1;
        foreach(@colors) { $_ = '0'.$_ if(($_<10) and ($_ !~ /^0/)); }
        @{$lk{data}{plugins}{'Fancify'}{colors}} = @colors;
        &{$lk{plugin}{"Fancify"}{utilities}{say}}($_[1]{irc},$_[2]{where},"Updated colors >>globally.");
      }
    },
    '^Fancy (\d{1,2},\s*\d{1,2})$' => {
      'description' => "Changes Fancify colors for a specific channel.",
      'tags' => ['utility'],
      'code' => sub {
        my @colors = split /\,\s*/, $1;
        foreach(@colors) { $_ = '0'.$_ if(($_<10) and ($_ !~ /^0/)); }
        @{$lk{data}{plugins}{'Fancify'}{$_[2]{where}}} = @colors;
        &{$lk{plugin}{"Fancify"}{utilities}{say}}($_[1]{irc},$_[2]{where},"Updated colors for $_[2]{where}!");
      }
    },
    '^Fancy$' => {
      'description' => "Changes Fancify colors for a specific channel.",
      'tags' => ['utility'],
      'code' => sub {
        delete $lk{data}{plugins}{'Fancify'}{$_[2]{where}};
        &{$lk{plugin}{"Fancify"}{utilities}{say}}($_[1]{irc},$_[2]{where},"Deleted colors for $_[2]{where}!");
      }
    }
  },
  'utilities' => {
    'main' => sub {
      my @colors = (14,13);
      if($_[1]) {
        lkDebug("Custom");
        @colors = @{$_[1]};
      }
      else {
        if($lk{data}{plugins}{'Fancify'}{colors}) {
          @colors = @{$lk{data}{plugins}{'Fancify'}{colors}};
          lkDebug("Custom Global");
        }
        else {
          lkDebug("Default");
        }
      }
      #($_[1])?(@{$_[1]}):($lk{data}{plugins}{'Fancify'}{colors})?(@{$lk{data}{plugins}{'Fancify'}{colors}}):[14,13];
      lkDebug("Using @colors");
      #my @colors = ($lk{data}{plugins}{'Fancify'}{colors})?@{$lk{data}{plugins}{'Fancify'}{colors}}:($_[1])?@{$_[1]}:(14,13);
      my $color = 0;
      my $string = "\cC$colors[0]".$_[0];
      my @string = split //, $string;
      foreach(@string) { if(/\x04/) { $color++; if($color >= @colors) { $color = 0; } $_ = "\cC$colors[$color]"; } }
      $string = join "", @string;
      $string =~ s/((?:\#|\@)+[\w\-\/.]+)/\cC$colors[1]$1\cC$colors[0]/g; # Hashtag/Channel coloring
      $string =~ s/([a-z]+:\/\/\S+\.[a-z]{2,6}\/?(?:[\/\w=?]+)?)/\cC$colors[1]$1\cC$colors[0]/gi; # URL coloring.
      $string =~ s/(?:\x05|>>)([\w]+)/\cC$colors[1]$1\cC$colors[0]/g; # >> or \x05 word coloring.
      $string =~ s/\cC\d{1,2}(?:,\d{1,2})?(\cC\d{1,2}(?:,\d{1,2})?)/$1/g; # Remove extra colorcodes.
      return $string;
    },
    'say' => sub {
      # Filehandle, Where, What.
      my @lines = split /\n/, $_[2];
      foreach(@lines) {
        if(/^\s*?$/) { next; }
        lkRaw($_[0],"PRIVMSG $_[1] :".&{$lk{plugin}{'Fancify'}{utilities}{main}}($_,
        ($lk{data}{plugins}{'Fancify'}{$_[1]})?
          $lk{data}{plugins}{'Fancify'}{$_[1]}:($lk{data}{plugins}{'Fancify'}{colors})?
            $lk{data}{plugins}{'Fancify'}{colors}:0));
        select(undef, undef, undef, 0.25) if(@lines > 2);
      }
    },
    'action' => sub {
      # Filehandle, Where, What.
      lkRaw($_[0],"PRIVMSG $_[1] :\x01ACTION ".&{$lk{plugin}{'Fancify'}{utilities}{main}}($_[2])."\x01");
    },
    'part' => sub {
      # Filehandle, Where, What.
      lkRaw($_[0],"PART $_[1] :".&{$lk{plugin}{'Fancify'}{utilities}{main}}($_[2]));
    }
  }
});