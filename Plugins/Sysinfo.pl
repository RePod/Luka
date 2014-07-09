addPlug('System', {
  'creator' => 'Caaz',
  'version' => '1.2',
  'description' => "It's for System information!",
  'name' => 'System Info',
  'dependencies' => ['Core_Utilities'],
  'code' => { 'load' => sub { if(!$lk{tmp}{plugin}{'System'}{$lk{os}}) { %{$lk{tmp}{plugin}{'System'}{$lk{os}}} = %{&{$lk{plugin}{'System'}{utilities}{get}}()}; } } },
  'utilities' => {
    'get' => sub {
      # Input: None
      # Output: Hash (name, os, version, manufacturer, model, type, memory)
      if($lk{os} =~ /MSWin32/) { 
        my $output = `systeminfo`;
        my @lines = split /\n/, $output;
        my %system = ();
        foreach(@lines) {
          if(/^Host Name\:\s+(.+)$/) { $system{name} = $1; }
          elsif(/^OS Name\:\s+(.+)$/) { $system{os} = $1; }
          elsif(/^OS Version\:\s+(.+)$/) { $system{version} = $1; }
          elsif(/^System Manufacturer\:\s+(.+)$/) { $system{manufacturer} = $1; }
          elsif(/^System Model\:\s+(.+)$/) { $system{model} = $1; }
          elsif(/^System Type\:\s+(.+)$/) { $system{type} = $1; }
          elsif(/^Total Physical Memory\:\s+(.+)$/) { $system{memory} = $1; }
          # Grab processors, it's on a different line!
        }
        return \%system;
      }
      elsif($lk{os} =~ /linux/i) {
        my %system = ();
        my @output = (split ' ', `uname -a`)[0..2];
        foreach(['name',1],['os',0],['version',2]) { $system{${$_}[0]} = $output[${$_}[1]];} 
        # Start working on more linux stuff, possibly with the help of Cinos.
        return \%system;
      }
      else {
        lkDebug("Need something for $lk{os}");
      }
    },
    'info' => sub {
      # Handle, Where
      if(!$lk{tmp}{plugin}{'System'}{$lk{os}}) { &{$utility{'Fancify_say'}}($_[0],$_[1],"Information hasn't been set. Perhaps there's no code for \x04$lk{os}\x04 yet?"); }
      else {
        my %sys = %{$lk{tmp}{plugin}{'System'}{$lk{os}}};
        my @output = ();
        foreach('name','os','version','memory','model','type') { push(@output, "[$_: \x04$sys{$_}\x04]") if($sys{$_}); }
        &{$utility{'Fancify_say'}}($_[0],$_[1],join " ", @output);
      }
    },
  },
  'commands' => {
    '^Sysinfo$' => {
      'description' => "Gets system information",
      'code' => sub {
        &{$utility{'System_info'}}($_[1]{irc},$_[2]{where});
      }
    },
    '^Meta$' => {
      'tags' => ['utility'],
      'description' => "Gets various information about this bot. Caaz's favorite command.",
      'code' => sub {
        my @files = (<./Plugins/*.pl>,$0);
        my %plugins = %{&{$utility{'Core_getAllPlugins'}}};
        my %sys = %{$lk{tmp}{plugin}{'System'}{$lk{os}}};
        my %count = ('lines'=>0,'comments'=>0);
        foreach(@files) {
          open NEW, "<".$_;
          my @lines = <NEW>;
          $count{lines} += @lines+0;
          foreach(@lines) { if($_ =~ /\#/) {$count{comments}++;} }
          close NEW;
        }
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"[\x04$lk{version}\x04] [".hostname()." \x04$sys{os}\x04] >>$count{lines} lines, >>$count{comments} comments, >>".@{$plugins{loaded}}." plugins loaded, >>".@{$plugins{unloaded}}." plugins not loaded, >>".@files." files.");
      }
    }
  },
});