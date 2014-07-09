addPlug('Twitter', {
  'creator' => 'Caaz',
  'version' => '1.1',
  'description' => "Something about Twitter functionality",
  'name' => 'Twitter',
  'dependencies' => ['Core_Command','Core_Utilities', 'Userbase'],
  'modules' => ['OAuth::Consumer'],
  'utilities' => {
    'sayTweet' => sub {
      # Input: Handle, Where, Tweet.
      
      ### Tweet
      # contributors =>
      # coordinates =>
      # created_at => Wed Jul 09 07:29:46 +0000 2014
      # entities => HASH(0x34c95c4)
      # favorite_count => 1
      # favorited => false
      # geo =>
      # id => 486774195045429249
      # id_str => 486774195045429249
      # in_reply_to_screen_name =>
      # in_reply_to_status_id =>
      # in_reply_to_status_id_str =>
      # in_reply_to_user_id =>
      # in_reply_to_user_id_str =>
      # lang => fr
      # place =>
      # possibly_sensitive => false
      # retweet_count => 0
      # retweeted => false
      # source => <a href="http://twitterfeed.com" rel="nofollow">twitterfeed</a>
      # text => Dominant Players http://t.co/1Ut2HEtTIV
      # truncated => false
      # user => HASH(0x26a997c)
      
      ### User
      # contributors_enabled => false
      # created_at => Tue Mar 18 20:10:04 +0000 2008
      # default_profile => true
      # default_profile_image => false
      # description => Unofficial XKCD Twitter RSS Stream.
      # entities => HASH(0x269a434)
      # favourites_count => 0
      # follow_request_sent => false
      # followers_count => 30332
      # following => true
      # friends_count => 2
      # geo_enabled => false
      # id => 14172171
      # id_str => 14172171
      # is_translation_enabled => false
      # is_translator => false
      # lang => en
      # listed_count => 1664
      # location =>
      # name => XKCD
      # notifications => false
      # profile_background_color => C0DEED
      # profile_background_image_url => http://abs.twimg.com/images/themes/theme1/bg.png
      # profile_background_image_url_https => https://abs.twimg.com/images/themes/theme1/bg.png
      # profile_background_tile => false
      # profile_image_url => http://pbs.twimg.com/profile_images/51864270/raptor_square_1_normal.png
      # profile_image_url_https => https://pbs.twimg.com/profile_images/51864270/raptor_square_1_normal.png
      # profile_link_color => 0084B4
      # profile_sidebar_border_color => C0DEED
      # profile_sidebar_fill_color => DDEEF6
      # profile_text_color => 333333
      # profile_use_background_image => true
      # protected => false
      # screen_name => xkcdrss
      # statuses_count => 1004
      # time_zone => London
      # url => http://t.co/iU1jkoHSB9
      # utc_offset => 3600
      # verified => false
      my %tweet = %{$_[2]};
      &{$utility{'Core_Utilities_debugHash'}}($tweet{user});
      &{$utility{'Fancify_say'}}($_[0],$_[1],"[\@$tweet{user}{screen_name} $tweet{user}{name}] $tweet{text}");
    },
    'ua' => sub {
      # Input: Server Name, Nickname
      my $handle = &{$utility{'Core_Utilities_getHandle'}}($_[0]);
      my %account = %{&{$utility{'Userbase_info'}}($_[0],$_[1])};
      my $ubID = &{$utility{'Userbase_getID'}}(\%account);
      if(($lk{data}{plugin}{'Twitter'}{key}) && ($lk{data}{plugin}{'Twitter'}{secret})) {
        if($account{name}) {
          if($lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{status} == 1) {
            return $lk{tmp}{plugin}{'Twitter'}{$_[0]}{$ubID}{ua};
          }
        }
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
                oauth_token_secret => $account{twitter}{token}
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
        if(&{$utility{'Twitter_set'}}($_[0],$_[2]{nickname}) == 1) {
          my $ua = &{$utility{'Twitter_ua'}}($_[0],$_[2]{nickname});
          my $response = $ua->get('https://api.twitter.com/1.1/statuses/home_timeline.json?count=5');
          my @tweets = @{decode_json($response->content())};
          lkDebug(join "\n", @tweets);
          foreach(@tweets) { &{$utility{'Twitter_sayTweet'}}($_[1]{irc},$_[2]{where},$_); }
          #&{$utility{"Core_Utility_debugHash"}}(\%home);
        }
      }
    },
    '^Twitter Auth (.+)$' => {
      'description' => "Gets the latest tweets on your home page. Up to 5 tweets.",
      'access' => 3,
      'code' => sub {
        my $pin = $1;
        if(&{$utility{'Twitter_set'}}($_[0],$_[2]{nickname},1) == 2) {
          &{$utility{'Twitter_auth'}}($_[0],$_[2]{nickname},$pin);
        }
      }
    }
  },
});