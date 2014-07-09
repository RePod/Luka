addPlug('Twitter', {
  'creator' => 'Caaz',
  'version' => '1.1',
  'description' => "Something about Twitter functionality",
  'name' => 'Twitter',
  'dependencies' => ['Core_Command','Core_Utilities', 'Userbase'],
  'modules' => ['HTML::Entities','OAuth::Consumer'],
  'utilities' => {
    'sayTweet' => sub {
      # Input: Handle, Where, Tweet.
      my %tweet = %{$_[2]};
      $tweet{text} =~ s/\n/ /g;
      &{$utility{'Fancify_say'}}($_[0],$_[1],"[\@$tweet{user}{screen_name} $tweet{user}{name}] ".decode_entities($tweet{text}));
    },
    'ua' => sub {
      # Input: Server Name, Nickname
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
      my %account = %{&{$utility{'Userbase_info'}}($_[0],$_[1])};
      my $ubID = &{$utility{'Userbase_getID'}}(\%account);
      if(($lk{data}{plugin}{'Twitter'}{key}) && ($lk{data}{plugin}{'Twitter'}{secret})) {
        if($account{name}) { if($lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{status} == 1) { return $lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{ua}; } }
      }
      return 0;
    },
    'auth' => sub {
      # Input: Server Name, Nickname, PIN
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
      my %account = %{&{$utility{'Userbase_info'}}($_[0],$_[1])};
      my $ubID = &{$utility{'Userbase_getID'}}(\%account);
      if(($lk{data}{plugin}{'Twitter'}{key}) && ($lk{data}{plugin}{'Twitter'}{secret})) {
        if($account{name}) {
          if($lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{status} == 2) {
            lkDebug("Doing '$_[2]'");
            my %params = ('oauth_verifier' => $_[2]);
            my ($token, $secret) = $lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{ua}->get_access_token(%params);
            $lk{data}{plugin}{'Userbase'}{users}{$_[0]}[$ubID]{twitter}{token} = $token;
            $lk{data}{plugin}{'Userbase'}{users}{$_[0]}[$ubID]{twitter}{secret} = $secret;
            $lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{status} = 1;
            &{$utility{'Fancify_say'}}($handle,$_[1],">>Success! Logged into Twitter. You're now free to use the twitter commands.");
            return 1;
          }
          else { &{$utility{'Fancify_say'}}($handle,$_[1],"You don't need to auth right now."); return 1; }
        }
        else {
          &{$utility{'Fancify_say'}}($handle,$_[1],"A >>Userbase account is required for this command. Make one with >>register >>password");
          return 0;
        }
      }
      else {
        &{$utility{'Fancify_say'}}($handle,$_[1],"The owner of this bot hasn't set up >>Twitter keys. This plugin won't work without them.");
        return 0;
      }
    },
    'set' => sub {
      # Input: Server Name, Nickname, make a new url?
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
                oauth_token_secret => $account{twitter}{secret}
              );
            }
            $lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{status} = 1;
            ## Insert a check here.
            return 1;
          }
          else {
            if(!$_[2]) {
              $lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{ua} = OAuth::Consumer->new(
                oauth_consumer_key => $lk{data}{plugin}{'Twitter'}{key},
                oauth_consumer_secret => $lk{data}{plugin}{'Twitter'}{secret},
                oauth_callback => 'oob',
                oauth_request_token_url => 'https://api.twitter.com/oauth/request_token',
                oauth_authorize_url => 'https://api.twitter.com/oauth/authorize',
                oauth_access_token_url => 'https://api.twitter.com/oauth/access_token'
              );
              $lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{status} = 2;
              &{$utility{'Fancify_say'}}($handle,$_[1],"You need to authorize your >>Twitter account at ".$lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{ua}->get_request_token());
              &{$utility{'Fancify_say'}}($handle,$_[1],"Once you get the PIN, use >>Twitter >>Auth >>PINNUMBER");
            }
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
    '^Twitter$' => {
      'description' => "Gets the latest tweets on your home page. Up to 5 tweets.",
      'access' => 3,
      'code' => sub {
        ## Move this to it's own utility.
        if(&{$utility{'Twitter_set'}}($_[0],$_[2]{nickname}) == 1) {
          my %account = %{&{$utility{'Userbase_info'}}($_[0],$_[2]{nickname})};
          my $ubID = &{$utility{'Userbase_getID'}}(\%account);
          my $ua = &{$utility{'Twitter_ua'}}($_[0],$_[2]{nickname});
          my $response;
          if($account{twitter}{since_home}) { lkDebug('Using since_home'); $response = $ua->get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=5&since_id='.$account{twitter}{since_home}); }
          else { $response = $ua->get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=5'); }
          my $content = decode_json($response->content());
          lkDebug("Got $content");
          if($content =~ /^HASH/) {
            &{$utility{"Core_Utilities_debugHash"}}($content);
            my %hash = %{$content};
            foreach(@{$hash{errors}}) {
              lkDebug($_);
              &{$utility{"Core_Utilities_debugHash"}}($_);
            }
          }
          else {
            return 1;
            my @tweets = @{$content};
            foreach(@tweets) { &{$utility{'Twitter_sayTweet'}}($_[1]{irc},$_[2]{where},$_); }
            if(!@tweets) { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},'No new tweets since your last check.'); }
            else { $lk{data}{plugin}{'Userbase'}{users}{$_[0]}[$ubID]{twitter}{since_home} = $tweets[0]{id}; }
            #&{$utility{"Core_Utility_debugHash"}}(\%home);
          }
        }
      }
    },
    '^Tweet (.+)$' => {
      'description' => "Updates your status on Twitter!",
      'access' => 3,
      'code' => sub {
        ## Move this to it's own utility.
        my $text = $1;
        if(&{$utility{'Twitter_set'}}($_[0],$_[2]{nickname}) == 1) {
          my $ua = &{$utility{'Twitter_ua'}}($_[0],$_[2]{nickname});
          my $response;
          if((length $text) < 140) {
            my %tweet = ('status' => $text);
            $response = $ua->post('https://api.twitter.com/1.1/statuses/update.json',%tweet);
            &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},'>>Tweeted!');
          }
          else { &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},'Tweet is too long, try again with a shorter tweet.'); }
        }
      }
    },
    '^Twitter Auth (.+)$' => {
      'description' => "Gets the latest tweets on your home page. Up to 5 tweets.",
      'access' => 3,
      'code' => sub {
        my $pin = $1;
        if(&{$utility{'Twitter_set'}}($_[0],$_[2]{nickname},1) == 2) { &{$utility{'Twitter_auth'}}($_[0],$_[2]{nickname},$pin); }
      }
    }
  },
});