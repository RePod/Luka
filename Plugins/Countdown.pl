addPlug("Count", {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Countdown',
  'dependencies' => ['Core_Utilities'],
  'utilities' => {
    'down' => sub {
      # Input: Handle, Channel, Comic ID.
      my @a = @{$_[1]}; 
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($a[0]);
      my $count = $a[2]-1;
      if($count <= 0) { &{$utility{'Fancify_say'}}($handle,$a[1],">>Go!"); }
      else {
        &{$utility{'Fancify_say'}}($handle,$a[1],">>$count...");
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
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>$count..."); 
          addTimer(time+1,{'name'=>$name,'code'=>$utility{"Count_down"},'args'=>[$_[0],$_[2]{where},$count]});
        }
      }
    },
    '^countdown (\d+) (\d+)$' => {
      'description' => "Starts a countdown with a ready countdown!",
      'code' => sub {
        my ($count, $wait) = ($1,$2);
        $lk{tmp}{plugin}{'Countdown'}{$_[0]}{$_[2]{where}}{count} = $count;
        $lk{tmp}{plugin}{'Countdown'}{$_[0]}{$_[2]{where}}{wait} = $wait;
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Waiting for >>$wait ".&{$utility{'Caaz_Utilities_pluralize'}}('user',$wait)." to use the >>ready command!");
      }
    },
    '^ready$' => {
      'description' => "Readies",
      'code' => sub {
        if($lk{tmp}{plugin}{'Countdown'}{$_[0]}{$_[2]{where}}{wait}) {
          $lk{tmp}{plugin}{'Countdown'}{$_[0]}{$_[2]{where}}{wait}--;
          if($lk{tmp}{plugin}{'Countdown'}{$_[0]}{$_[2]{where}}{wait} <= 0) {
            my $count = $lk{tmp}{plugin}{'Countdown'}{$_[0]}{$_[2]{where}}{count};
            my $name = 'countdown'.$_[0].$_[2]{where};
            $count = 15 if($count > 15);
            my $caught = 0;
            foreach $time (keys %{$lk{timer}}) { foreach(@{$lk{timer}{$time}}) { $caught = 1 if(${$_}{name} eq $name); } }
            if($caught) { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"There's already a countdown here."); }
            else {
              &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>$count..."); 
              addTimer(time+1,{'name'=>$name,'code'=>$utility{"Count_down"},'args'=>[$_[0],$_[2]{where},$count]});
            }
          }
          else {
            &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Waiting for >>$lk{tmp}{plugin}{'Countdown'}{$_[0]}{$_[2]{where}}{wait} more ".&{$utility{'Caaz_Utilities_pluralize'}}('user',$lk{tmp}{plugin}{'Countdown'}{$_[0]}{$_[2]{where}}{wait}).'.');
          }
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