addPlug('Core', {
  'creator' => 'Caaz',
  'version' => '2',
  'name' => 'Core',
  'dependencies' => ['Fancify','Core_Utilities'],
  'description' => "This is the newest Core plugin. It covers bot managemeent, and the typical commands that should only be available to the owner.",
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
      return 1;
    },
    'getNetworks' => sub {
      # Input: None
      # Output: Array of network
      my @output = @{$lk{data}{networks}};
      foreach(@output) { if(&{$utility{'Core_Utilities_getHandle'}}(${$_}{name})) { ${$_}{connected} = 1; } }
      return \@output;
    },
    'getNetworkString' => sub {
      # Input: Network Hash, Type
      # Output: True if success
      # 0: Short
      # 1: Long
      my $string = '';
      my %network = %{$_[0]};
      if(!$_[1]) {
        return "\x04$network{name}\x04" if(($network{connected}) && (!$network{disabled}));
        return "$network{name}" if((!$network{connected}) || ($network{disabled}));
      }
      elsif($_[1] == 1) {
        if($network{connected}) {
          return "[\x04$network{name}\x04] [Disabled] [$network{host}:$network{port}] [>>".(@{$network{autojoin}}).&{$utility{'Caaz_Utilities_pluralize'}}(' autojoin', @{$network{autojoin}}+0).".]" if($network{disable});
          return "[\x04$network{name}\x04] [>>Enabled] [$network{host}:$network{port}] [>>".(@{$network{autojoin}}).&{$utility{'Caaz_Utilities_pluralize'}}(' autojoin', @{$network{autojoin}}+0).".]" if(!$network{disable});
        }
        else {
          return "[$network{name}] [Disabled] [$network{host}:$network{port}] [>>".(@{$network{autojoin}}).&{$utility{'Caaz_Utilities_pluralize'}}(' autojoin', @{$network{autojoin}}+0).".]" if($network{disable});
          return "[$network{name}] [>>Enabled] [$network{host}:$network{port}] [>>".(@{$network{autojoin}}).&{$utility{'Caaz_Utilities_pluralize'}}(' autojoin', @{$network{autojoin}}+0).".]" if(!$network{disable});
        }
      }
      return 0;
    },
    'showNetworks' => sub {
      # Input: Handle, Where, Type
      # 0: Short
      # 1: Long
      my @networks = @{&{$utility{'Core_getNetworks'}}};
      if(!$_[2]) {
        my @output = ();
        my $i = 0;
        foreach(@networks) { push(@output,"[>>$i: ".&{$utility{'Core_getNetworkString'}}($_,$_[2])."]"); $i++; }
        &{$utility{'Fancify_say'}}($_[0],$_[1],join " ", @output);
      }
      else {
        my $i = 0;
        foreach(@networks) { &{$utility{'Fancify_say'}}($_[0],$_[1],">>$i: ".&{$utility{'Core_getNetworkString'}}($_,$_[2])); $i++; }
      }
      return 1;
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
      return 1;
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
    '^End$' => {
      'tags' => ['utility'],
      'description' => "Closes Luka.",
      'access' => 3,
      'code' => \&lkEnd
    },
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
    '^Plugins (Un)?loaded$' => {
      'description' => "Lists all Loaded or Unloaded plugins.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub { my $un = $1; my $type = 0; $type = 1 if($un); &{$utility{'Core_showPlugins'}}($_[1]{irc},$_[2]{where},$type); }
    },
    '^Plugins (Disable|Enable) (.+)$' => {
      'description' => "Disables or Enables a list of plugins by key.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub {
        my $command = lc $1;
        my $type = 0; $type = 1 if($command eq 'disable');
        my @keys = split /\s+/, $2;
        my $count = 0;
        foreach(@keys) { $count += &{$utility{'Core_setPluginDisabled'}}($_,$type); }
        if($count) {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>$count ".&{$utility{'Caaz_Utilities_pluralize'}}('plugin', $count).' '.$command.'d. >>Refreshing...');
          &{$utility{'Core_reloadSay'}}($_[1]{irc},$_[2]{where},1);
        }
        else { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},'No plugins affected.'); }
      }
    },
    '^Networks (.+)$' => {
      'description' => "Lists, disables, or enables networks.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub {
        my $command = $1;
        if($command =~ /^list( long)?$/i) {
          my $type = $1;
          &{$utility{'Core_showNetworks'}}($_[1]{irc},$_[2]{where},1) if(($type) && ($type =~ /long$/i));
          &{$utility{'Core_showNetworks'}}($_[1]{irc},$_[2]{where}) if((!$type) || ($type =~ /^$/));
        }
        elsif($command =~ /^(en|dis)able (.+)$/i) {
          my ($what,$target) = ($1,$2);
          my @type = ('Enabled');
          if($what =~ /^d/i) { @type = ('Disabled',1); }
          if($lk{data}{networks}[$target]) {
            if($type[1]) { lkDebug("Disabling."); $lk{data}{networks}[$target]{disable} = 1; }
            else { delete $lk{data}{networks}[$target]{disable}; }
            &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},">>$type[0] network \x04$lk{data}{networks}[$target]{name}\x04");
            # Disconnect/connect code?
            lkSave();
          }
          else {
            &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"No network with that >>ID.");
          }
        }
      }
    },
    '^\! (.+)$' => {
      'tags' => ['utility'],
      'description' => "Executes perl code.",
      'access' => 3,
      'code' => sub {
        my $code = $1;
        my @result = split /\n|\r/, eval $code;
        if($@) { lkRaw($_[1]{irc},"PRIVMSG $_[2]{where} :".(join "\|", split /\r|\n/, $@)); }
        else { lkRaw($_[1]{irc},"PRIVMSG $_[2]{where} :".(join "\|", @result)); }
      }
    },
    '^Announce (.+)$' => {
      'description' => "Announces to all of the bot's channels.",
      'tags' => ['utility'],
      'access' => 3,
      'code' => sub { my $msg = $1; foreach(@{$lk{data}{networks}[$lk{tmp}{connection}{fileno($_[1]{irc})}]{autojoin}}) { &{$utility{'Fancify_say'}}($_[1]{irc},$_,$msg); } }
    },
    '^Autojoin (.+)' => {
      'tags' => ['utility'],
      'description' => "Add, Del, or List Autojoins.",
      'access' => 2,
      'code' => sub {
        my $command = $1;
        my @autojoin = sort @{$lk{data}{networks}[$lk{tmp}{connection}{fileno($_[1]{irc})}]{autojoin}};
        if($command =~ /^list$/i) { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"[".(join "] [", @autojoin)."]"); }
        elsif($command =~ /^add (\#.+)$/i) { 
          my @channels = split /,\s*/, $1; 
          push(@autojoin, @channels); 
          foreach(@channels) { lkRaw($_[1]{irc},"JOIN :$_"); }
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Added [".(join "] [", @channels)."] to autojoin.");
        }
        elsif($command =~ /^del (.+)$/i) {
          my $regex = $1;
          my @removed = grep(/$regex/i, @autojoin);
          @autojoin = grep(!/$regex/i, @autojoin);
          foreach(@removed) { &{$utility{'Fancify_part'}}($_[1]{irc},$_,"Removed $_ from autojoin."); }
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Removed >>".@removed." ".&{$utility{'Caaz_Utilities_pluralize'}}('channel', @removed+0)." matching [\x04/\x04\x04$regex\x04\x04/i\x04]");
        }
        else { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"You're doing something wrong. Autojoin commands are >>Add #Channel, >>Del #Channel, or >>List"); }
        @autojoin = &{$utility{'Core_Utilities_uniq'}}(@autojoin);
        @{$lk{data}{networks}[$lk{tmp}{connection}{fileno($_[1]{irc})}]{autojoin}} = @autojoin;
      }
    },
    '^Ignore (.+)' => {
      'tags' => ['utility'],
      'description' => "Add, Del, or List ignores.",
      'access' => 2,
      'code' => sub {
        my $command = $1;
        my @ignore = sort @{$lk{data}{plugin}{"Core_Ignore"}{ignore}};
        if($command =~ /^list$/i) { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"[\x04".(join "\x04] [\x04", @ignore)."\x04]"); }
        elsif($command =~ /^add (.+)$/i) { 
          my @ignores = split /,\s*/, $1; 
          push(@ignore, @ignores); 
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Added [\x04".(join "\x04] [\x04", @ignores)."\x04] to ignores.");
        }
        elsif($command =~ /^del (.+)$/i) { 
          my ($string,$position) = ($1,0); my @catch = ();
          foreach $regex (@ignore){ if($string =~ /$regex/i) { push(@catch, $position); } $position++; }
          foreach(@catch) { delete $ignore[$_]; }
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Removed >>".(@catch+0)." ".&{$utility{'Caaz_Utilities_pluralize'}}('ignore', @catch+0)." matching \x04$string\x04");
        }
        else { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"You're doing something wrong. Ignore commands are >>Add >>regex, >>Del >>string, or >>List"); }
        @ignore = &{$utility{'Core_Utilities_uniq'}}(grep !/^$/, @ignore);
        @{$lk{data}{plugin}{"Core_Ignore"}{ignore}} = @ignore;
      }
    }
  }
});