addPlug("count", {
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'xkcd',
  'dependencies' => ['Core_Utilities'],
  'modules' => ['HTML::Entities', 'LWP::Simple'],
  'utilities' => {
    'down' => sub {
      # Input: Handle, Channel, Comic ID.
      my @a = @{$_[1]}; 
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($a[0]);
      my $count = $a[2]-1;
      if($count <= 0) { &{$utility{'Fancify_say'}}($handle,$a[1],">>Go!"); }
      else {
        &{$utility{'Fancify_say'}}($handle,$a[1],">>$count...");
        addTimer(time+1,{'name'=>$name,'code'=>$utility{"count_down"},'args'=>[$a[0],$a[1],$count]});
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
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Counting down!"); 
          addTimer(time+1,{'name'=>$name,'code'=>$utility{"count_down"},'args'=>[$_[0],$_[2]{where},$count]});
        }
      }
    }
  }
});