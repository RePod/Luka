addPlug("Get",{
  'creator' => 'Caaz',
  'version' => '1',
  'name' => 'Lazy Updates',
  'dependencies' => ['Fancify','Core_Utilities'],
  'modules' => ['LWP::Simple'],
  'description' => "Grabs plugins from the github repository and reloads it.",
  'commands' => {
    '^Get (\w+)$' => {
      'access' => 3,
      'description' => "Grab something from the main Github repository.",
      'code' => sub {
        my $plugin = $1;
        my $result = getstore("https://raw.githubusercontent.com/Caaz/Luka/master/Plugins/".$plugin.".pl",'./Plugins/'.$plugin.".pl");
        if($result == 200) {
          $utility{'Fancify_say'}($_[1]{irc},$_[2]{where},"Success! Reloading...");
          $utility{'Core_reloadSay'}($_[1]{irc},$_[2]{where},0);
        }
        else {
          $utility{'Fancify_say'}($_[1]{irc},$_[2]{where},"Nothing! >>$result!");
        }
      }
    },
  },
});