addPlug("Count", {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Countdown',
  'dependencies' => ['Core_Utilities'],
  'utilities' => {
    'dec2bin' => sub {
      my $str = unpack("B32", pack("N", shift));
      $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
      return $str;
    },
    'down' => sub {
      # Input: Handle, Channel, Comic ID.
      my @a = @{$_[1]}; 
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($a[0]);
      my $count = $a[2]-1;
      if($count <= 0) { &{$utility{'Fancify_say'}}($handle,$a[1],">>Go!"); }
      else {
        &{$utility{'Fancify_say'}}($handle,$a[1],">>".&{$utility{'Count_dec2bin'}}($count)."...");
        addTimer(time+1,{'name'=>$a[0],'code'=>$utility{"Count_down"},'args'=>[$a[0],$a[1],$count]});
      }
      return 1;
    }
  },
  'commands' => {
    '^countdown (\d+)$' => {
      'description' => "Starts a countdown.",
      'code' => sub {
        my $count = $1;
        my $name = 'countdown'.$_[0].$_[2]{where};
        $count = 15 if($count > 15);
        my $caught = 0;
        foreach $time (keys %{$lk{timer}}) { foreach(@{$lk{timer}{$time}}) { $caught = 1 if(${$_}{name} eq $name); } }
        if($caught) { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"There's already a countdown here."); }
        else {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>".&{$utility{'Count_dec2bin'}}($count)."..."); 
          addTimer(time+1,{'name'=>$name,'code'=>$utility{"Count_down"},'args'=>[$_[0],$_[2]{where},$count]});
        }
      }
    },
    '^countdown$' => {
      'description' => "Starts a countdown.",
      'code' => sub {
        my $count = 5;
        my $name = 'countdown'.$_[0].$_[2]{where};
        $count = 15 if($count > 15);
        my $caught = 0;
        foreach $time (keys %{$lk{timer}}) { foreach(@{$lk{timer}{$time}}) { $caught = 1 if(${$_}{name} eq $name); } }
        if($caught) { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"There's already a countdown here."); }
        else {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>".&{$utility{'Count_dec2bin'}}($count)."..."); 
          addTimer(time+1,{'name'=>$name,'code'=>$utility{"Count_down"},'args'=>[$_[0],$_[2]{where},$count]});
        }
      }
    }
  }
});