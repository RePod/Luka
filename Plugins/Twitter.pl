addPlug('Twitter', {
  'creator' => 'Caaz',
  'version' => '1.1',
  'description' => "Something about Twitter functionality",
  'name' => 'Twitter',
  'dependencies' => ['Core_Command','Core_Utilities', 'Userbase'],
  'modules' => ['OAuth::Consumer'],
  'utilities' => {
    'setUA' => sub {
      # Input: Server Name, Userbase ID
    },
    'auth' => sub {
      # Input: Server Name, Nickname
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
      my %account = %{&{$utility{'Userbase_info'}}($_[0],$_[1])};
      my $ubID = &{$utility{'Userbase_getID'}}(\%account);
      if(($lk{data}{plugin}{'Twitter'}{key}) && ($lk{data}{plugin}{'Twitter'}{secret})) {
        if($account{name}) {
          if($lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{status} == 2) {
            my ($token, $secret) = $lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{ua}->get_access_token();
            $lk{data}{plugin}{'Userbase'}{users}{$_[0]}[$ubID]{twitter}{token} = $token;
            $lk{data}{plugin}{'Userbase'}{users}{$_[0]}[$ubID]{twitter}{secret} = $secret;
            &{$utility{'Fancify_say'}}($handle,$_[1],"Set $token and $secret");
          }
          else {
            &{$utility{'Fancify_say'}}($handle,$_[1],"You don't need to auth right now.");
          }
        }
        else {
          &{$utility{'Fancify_say'}}($handle,$_[1],"A >>Userbase account is required for this command. Make one with >>register >>password");
          return 0;
        }
      }
      else {
        # No key or secret set
        &{$utility{'Fancify_say'}}($handle,$_[1],"The owner of this bot hasn't set up >>Twitter keys. This plugin won't work without them.");
        return 0;
      }
    },
    'set' => sub {
      # Input: Server Name, Nickname
      # Output: ID, UA
      # 0 : Failure
      # 1 : Properly set UA.
      # 2 : Set UA, but user needs to authorize.
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
      my %account = %{&{$utility{'Userbase_info'}}($_[0],$_[1])};
      my $ubID = &{$utility{'Userbase_getID'}}(\%account);
      if(($lk{data}{plugin}{'Twitter'}{key}) && ($lk{data}{plugin}{'Twitter'}{secret})) {
        if($account{name}) {
          if(($account{twitter}{token}) && ($account{twitter}{token})) {
            if(!$lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{ua}) {
              lkDebug("Setting Useragent for $_[0] - $ubID");
              $lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{ua} = OAuth::Consumer->new(
                oauth_consumer_key => $lk{data}{plugin}{'Twitter'}{key},
                oauth_consumer_secret => $lk{data}{plugin}{'Twitter'}{secret},
                oauth_token_=> $account{twitter}{token},
                oauth_token_secret => $account{twitter}{token}
              );
            }
            $lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{status} = 1;
            ## Insert a check here.
            return 1;
          }
          else {
            $lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{ua} = OAuth::Consumer->new(
              oauth_consumer_key => $lk{data}{plugin}{'Twitter'}{key},
              oauth_consumer_secret => $lk{data}{plugin}{'Twitter'}{secret},
              oauth_request_token_url => 'https://api.twitter.com/oauth/request_token',
              oauth_authorize_url => 'https://api.twitter.com/oauth/authorize',
              oauth_access_token_url => 'https://api.twitter.com/oauth/access_token'
            );
            $lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{status} = 2;
            &{$utility{'Fancify_say'}}($handle,$_[1],"Using $lk{data}{plugin}{'Twitter'}{key} and $lk{data}{plugin}{'Twitter'}{secret}");
            &{$utility{'Fancify_say'}}($handle,$_[1],"You need to authorize your >>Twitter account at ".$lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{ua}->get_request_token());
            return 2;
          }
        }
        else {
          &{$utility{'Fancify_say'}}($handle,$_[1],"A >>Userbase account is required for this command. Make one with >>register >>password");
          return 0;
        }
      }
      else {
        # No key or secret set
        &{$utility{'Fancify_say'}}($handle,$_[1],"The owner of this bot hasn't set up >>Twitter keys. This plugin won't work without them.");
        return 0;
      }
    },
  },
  'commands' => {
    '^Twitter set (.+?) (.+)$' => {
      'description' => "Sets OAuth keys for Twitter usage.",
      'access' => 3,
      'code' => sub {
        my ($key,$value) = ($1,$2);
        $lk{data}{plugin}{'Twitter'}{$key} = $value;
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Set >>$key to >>$value");
      }
    },
    '^Twitter Home$' => {
      'description' => "Gets the latest tweets on your home page. Up to 5 tweets.",
      'access' => 3,
      'code' => sub {
        if(&{$utility{'Twitter_set'}}($_[0],$_[2]{nickname}) == 1) {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Set worked!");
        }
      }
    },
    '^Twitter Auth$' => {
      'description' => "Gets the latest tweets on your home page. Up to 5 tweets.",
      'access' => 3,
      'code' => sub {
        if(&{$utility{'Twitter_set'}}($_[0],$_[2]{nickname}) == 2) {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Checking Auth...");
          &{$utility{'Twitter_auth'}}($_[0],$_[2]{nickname})
        }
      }
    }
  },
});