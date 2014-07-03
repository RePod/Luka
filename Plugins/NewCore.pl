addPlug('Core', {
  'creator' => 'Caaz',
  'version' => '2',
  'name' => 'Core',
  'dependencies' => ['Fancify','Core_Utilities'],
  'description' => "A new Core plugin to replace old functions.",
  'utilities' => {
    'pluginAll' => sub {
      # Input: What
      foreach(keys %{$lk{plugin}}) { &{$lk{plugin}{$_}{code}{$_[0]}}({'data' => $lk{data}{plugin}{$_}, 'tmp' => $lk{tmp}{plugin}{$_}}) if($lk{plugin}{$_}{code}{$_[0]}); }
      return 1;
    },
    'restart' => sub { exec('perl Luka.pl'); },
    'reload' => sub {
      # Input: Type
      # 0 : Only load new plugins
      # 1 : Load all plugins
      my $startTime = time;
      if(!$_[0]) { &{$utility{'Core_pluginAll'}}('unload'); }
      elsif($_[0] == 1) { lkUnloadPlugins(); }
      return {'time'=>(time-$startTime),'errors' => lkLoadPlugins()};
    },
    'reloadSay' => sub {
      # Input: Handle, Where, Type
      my %return = %{&{$utility{'Core_reload'}}($_[2])};
      &{$utility{'Fancify_say'}}($_[0],$_[1],"Reloaded. [>>$return{time} ".&{$utility{'Caaz_Utilities_pluralize'}}("second", $return{time})."] [>>".@{$return{errors}}.' '.&{$utility{'Caaz_Utilities_pluralize'}}("error", @{$return{errors}})."]");
      foreach(@{$return{errors}}) {
        my @msg = split /\n/, ${$_}{message};
        @msg = grep !/^\s+?$/, @msg;
        &{$utility{'Fancify_say'}}($_[0],$_[1],"[\x04${$_}{plugin}\x04] ".$msg[0]);
      }
    },
    'getAllPlugins' => sub {
      # Input: None
      # Output: An array of plugins, sorted by name, filled with info!
      my %output;
      foreach $plug (keys %{$lk{plugin}}) {
        my %plugin = (key=>$plug);
        foreach('name','creator','version','description') { $plugin{$_} = $lk{plugin}{$plug}{$_} if($lk{plugin}{$plug}{$_}); }
        if(!$lk{data}{disablePlugin}{$plug}) { push(@{$output{loaded}}, \%plugin); }
        else { push(@{$output{unloaded}}, \%plugin); }
      }
      foreach $load ('loaded','unloaded') { @{$output{$load}} = sort { lc(${$a}{key}) cmp lc(${$b}{key}) } @{$output{$load}}; }
      return \%output;
    },
    'getPluginString' => sub {
      # Input: Plugin, Type
      # 0: Short
      my %plugin = %{$_[0]};
      my $type = $_[1];
     # &{$utility{'Core_Utilities_debugHash'}}(\%plugin);
      my $string = '';
      if((!$type) || ($type == 0)) {
        $string .= "[\x04$plugin{key}\x04]";
      }
      return $string;
    },
    'showPlugins' => sub {
      # Input: Handle, Where, type
      my %plugins = %{&{$utility{'Core_getAllPlugins'}}};
      my @output;
      if((!$_[2]) || ($_[2] == 0)) {
        &{$utility{'Fancify_say'}}($_[0],$_[1],">>".@{$plugins{loaded}}." plugins loaded.");
        foreach(@{$plugins{loaded}}) { push(@output, &{$utility{'Core_getPluginString'}}($_,0)); }
      }
      else {
        &{$utility{'Fancify_say'}}($_[0],$_[1],">>".@{$plugins{unloaded}}." plugins not loaded.");
        foreach(@{$plugins{unloaded}}) { push(@output, &{$utility{'Core_getPluginString'}}($_,0)); }
      }
      my $string = '';
      foreach(@output) {
        $string .= $_.' ';
        if((split //, $string) > 300) { &{$utility{'Fancify_say'}}($_[0],$_[1],$string); $string = ''; }
      }
      if($string !~ /^$/) { &{$utility{'Fancify_say'}}($_[0],$_[1],$string); }
      #lkDebug(join ", ", @output);
    },
    'setPluginDisabled' => sub {
      # Input : Plugin Key, true/false
      # Output : Plugin key name if succeeded, 0 if nothing.
      my $output = 0;
      foreach $plug (keys %{$lk{plugin}}) { lkDebug("Checking $plug against $_[0]"); if($plug =~ /^$_[0]$/i) { lkDebug('disabled'); $output = 1; $lk{data}{disablePlugin}{$plug} = $_[1]; } }
      return $output;
    }
  },
  'commands' => {
    '^Reload$' => {
      'description' => "Reloads any new code added to plugins.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub { &{$utility{'Core_reloadSay'}}($_[1]{irc},$_[2]{where},0); }
    },
    '^Refresh$' => {
      'description' => "Reloads all plugins.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub { &{$utility{'Core_reloadSay'}}($_[1]{irc},$_[2]{where},1); }
    },
    '^Restart$' => {
      'description' => "Restarts the entire bot.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub { &{$utility{'Core_restart'}}(); }
    },
    '^Plugins Loaded$' => {
      'description' => "Lists all Loaded plugins.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub { &{$utility{'Core_showPlugins'}}($_[1]{irc},$_[2]{where},0); }
    },
    '^Plugins Unloaded$' => {
      'description' => "Lists all Unloaded plugins.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub { &{$utility{'Core_showPlugins'}}($_[1]{irc},$_[2]{where},1); }
    },
    '^Plugins Disable (.+)$' => {
      'description' => "Disables a list of plugins by key.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub {
        my @keys = split /\s+/, $1;
        my $count = 0;
        foreach(@keys) { $count += &{$utility{'Core_setPluginDisabled'}}($_,1); }
        if($count) {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>$count ".&{$utility{'Caaz_Utilities_pluralize'}}('plugin', $count).' disabled. >>Refreshing...');
          &{$utility{'Core_reloadSay'}}($_[1]{irc},$_[2]{where},1);
        }
        else { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},'No plugins affected.'); }
      }
    },
    '^Plugins Enable (.+)$' => {
      'description' => "Enables a list of plugins by key.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub {
        my @keys = split /\s+/, $1;
        my $count = 0;
        foreach(@keys) { $count += &{$utility{'Core_setPluginDisabled'}}($_,0); }
        if($count) {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>$count ".&{$utility{'Caaz_Utilities_pluralize'}}('plugin', $count).' enabled. >>Refreshing...');
          &{$utility{'Core_reloadSay'}}($_[1]{irc},$_[2]{where},1);
        }
        else { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},'No plugins affected.'); }
      }
    },
    '^Announce (.+)$' => {
      'description' => "Announces to all of the bot's channels.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub {
        my $msg = $1;
        foreach(@{$lk{data}{networks}[$lk{tmp}{connection}{fileno($_[1]{irc})}]{autojoin}}) { &{$utility{'Fancify_say'}}($_[1]{irc},$_,$msg); }
      }
    },
  }
});