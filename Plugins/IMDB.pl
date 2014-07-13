addPlug('IMDB', {
  name => 'IMDB Search',
  description => "This is a plugin to access the api at omdbapi.com",
  creator => 'Caaz',
  version => '1',
  modules => ['LWP::Simple'],
  dependencies => ['Fancify', 'Core_Utilities'],
  utilities => {
    'search' => sub {
      #Input: Handle, Where, Search, Limit
      #Output: Hash of Results
      my $searchPage = get('http://www.omdbapi.com/?s='.$_[2]);
      $searchPage =~ s/[!\P{IsASCII}]//g;
      %results = %{decode_json($searchPage)};
      &{$utility{'Core_Utilities_debugHash'}}(\%results);
      my $i = 0;
      foreach(@{$results{'Search'}}) {
        my $content = get('http://www.omdbapi.com/?i='.${$_}{imdbID});
        $content =~ s/[!\P{IsASCII}]//g;
        %imdb = %{decode_json($content)};
        &{$utility{'Fancify_say'}}($_[0],$_[1],"[\x04$imdb{Title} ($imdb{Year})\x04] [$imdb{Runtime}] $imdb{Plot}");
        # {"Title":"I, Robot",
        # "Year":"2004",
        # "Rated":"PG-13",
        # "Released":"16 Jul 2004",
        # "Runtime":"115 min",
        # "Genre":"Action, Mystery, Sci-Fi",
        # "Director":"Alex Proyas",
        # "Writer":"Jeff Vintar (screenplay), Akiva Goldsman (screenplay), Jeff Vintar (screen story), Isaac Asimov (suggested by book)",
        # "Actors":"Will Smith, Bridget Moynahan, Alan Tudyk, James Cromwell",
        # "Plot":"In 2035 a technophobic cop investigates a crime that may have been perpetrated by a robot, which leads to a larger threat to humanity.",
        # "Language":"English",
        # "Country":"USA, Germany",
        # "Awards":"Nominated for 1 Oscar. Another 1 win & 11 nominations.",
        # "Poster":"http://ia.media-imdb.com/images/M/MV5BMTQwNzI5NTQ0OF5BMl5BanBnXkFtZTYwMTI3Mjk2._V1_SX300.jpg",
        # "Metascore":"59",
        # "imdbRating":"7.1",
        # "imdbVotes":"278,722",
        # "imdbID":"tt0343818",
        # "Type":"movie",
        # "Response":"True"}
        $i++; if((!$_[3]) || ($i > $_[3])) { last; }
      }
    },
  },
  commands => {
    '^IMDB (.+)$' => {
      code => sub {
        my $search = $1;
        &{$utility{'IMDB_search'}}($_[1]{irc},$_[2]{where},$search);
      }
    }
  },
});