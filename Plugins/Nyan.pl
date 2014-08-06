addPlug('Nyan_Cat', {
  'creator' => 'Caaz',
  'version' => '1',
  'description' => "Nyan-Cat-Call someone via IRC!",
  'name' => 'Nyan Cat Call',
  'modules' => ['LWP::UserAgent'],
  'utilities' => {
    'call' => sub {
      # Input: Phone number
      # Output: Succeed?
      my $number = $_[0];
      $number =~ s/\D//g;
      if($number !~ /\d{9}/) { return 0; }
      my $ua = LWP::UserAgent->new();
      my $response = $ua->post('http://www.nyancatcall.com/?action=call',{phone=>$number});
      return 1;
    },
  },
  'commands' => {
    '^NyanCatCall (.+)' => {
      'description' => "Calls a phone number as nyan cat!",
      'code' => sub {
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},(&{$utility{'Nyan_Cat_call'}}($1))?"Calling as \x04Nyan Cat\x04...":"There's a problem with that phone number! It must be a 9 digit phone number. United states, area code included.");
      }
    }
  }
});