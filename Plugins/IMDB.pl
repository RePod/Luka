addPlug('IMDB', {
  name => 'IMDB Search',
  description => "This is a plugin to access the api at omdbapi.com",
  creator => 'Caaz',
  version => '1',
  modules => ['LWP::Simple'],
  dependencies => ['Fancify', 'Core_Utilities'],
  utilities => {
    'search' => sub {
      #Input: Handle, Where, Search, Limit, include plot?
      #Output: Hash of Results
      my $searchPage = get('http://www.omdbapi.com/?s='.$_[2]);
      $searchPage =~ s/[!\P{IsASCII}]/-/g;
      %results = %{decode_json($searchPage)};
      &{$utility{'Core_Utilities_debugHash'}}(\%results);
      my $i = 0;
      foreach(@{$results{'Search'}}) {
        my $content = get('http://www.omdbapi.com/?i='.${$_}{imdbID});
        $content =~ s/[!\P{IsASCII}]/-/g;
        %imdb = %{decode_json($content)};
        &{$utility{'Fancify_say'}}($_[0],$_[1],"[http://www.imdb.com/title/$imdb{imdbID}] [\x04$imdb{Title}\x04 ($imdb{Year})] [\x04$imdb{imdbRating}/10\x04] [\x04$imdb{Genre}\x04]") if(!$_[4]);
        &{$utility{'Fancify_say'}}($_[0],$_[1],"[http://www.imdb.com/title/$imdb{imdbID}] [\x04$imdb{Title}\x04 ($imdb{Year})] [\x04$imdb{Genre}\x04] [\x04$imdb{imdbRating}/10\x04] [$imdb{Runtime}] $imdb{Plot}") if($_[4]);
        $i++; if((!$_[3]) || ($i > $_[3])) { last; }
      }
    },
  },
  commands => {
    '^IMDB (.+)$' => {
      code => sub {
        my $search = $1;
        if($_[2]{where} =~ /moonspace$/i) { &{$utility{'IMDB_search'}}($_[1]{irc},$_[2]{where},$search,0,0); }
        else { &{$utility{'IMDB_search'}}($_[1]{irc},$_[2]{where},$search,0,1); }
      }
    }
  },
});