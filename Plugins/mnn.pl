addPlug('Mnn', {
  name => 'mnn.im API',
  description => "This is a plugin to access the mnn.im API!",
  creator => 'Caaz',
  version => '1',
  modules => ['LWP::UserAgent'],
  dependencies => ['Fancify', 'Core_Utilities'],
  utilities => {
    'shorten' => sub {
      my $ua = LWP::UserAgent->new();
      my %result = %{decode_json($ua->post('http://mnn.im/s',$_[0])->decoded_content())};
      &{$utility{'Core_Utilities_debugHash'}}($result{url});
      if($result{status} eq 'success') {
        return $result{url}{short_url};
      }
      else {
        return "broken.";
      }
    },
  },
  commands => {
    '^Shorten (.+)$' => {
      cooldown => 3,
      code => sub {
        my $url = $1;
        &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"Your shortened URL is ".&{$utility{'Mnn_shorten'}}($url));
      }
    }
  },
});