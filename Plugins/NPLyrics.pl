addPlug('NP_Lyrics', {
  name => 'Now Playing with Lyrics',
  description => "Connects the Lyrics plugin with the NP plugin.",
  creator => 'Caaz',
  version => '1',
  dependencies => ['Foobar','Lyrics','Core_Utilities','Core_Command'],
  commands => {
    '^NP Lyrics(\w+)?$' => {
      'tags' => ['utility','media'],
      'description' => "Ges NP info!",
      'example' => "NPCaaz\nNP",
      'code' => sub {
        my $server = $1;
        #&{$utility{'Foobar_getInfo'}};
        $server = $_[2]{username} if(!$server);
        my $caught = 0;
        foreach (@{$lk{data}{plugin}{'Foobar'}{servers}}) { if(${$_}{name} =~ /$server/) { &{$lk{plugin}{'Foobar'}{utilities}{connect}}($_); } }
        foreach(values %{$lk{tmp}{plugin}{'Foobar'}{handles}}) {
          lkDebug(${$_}{name});
          if(${$_}{name} =~ /^$server$/i) {
            $caught++;
            print {${$_}{filehandle}} "trackinfo\n";
            &{$utility{'Foobar_getInfo'}};
            &{$utility{'Foobar_npSay'}}($_[1]{irc},$_[2]{where},$_);
            &{$utility{'Lyrics_show'}}($_[1]{irc}, $_[2]{where}, &{$utility{'Lyrics_get'}}(${$_}{info}{artist},${$_}{info}{title}), 100);
          }
        }
        if(!$caught) {
          &{$utility{'Fancify_say'}}($_[1]{irc},$_[2]{where},"$server not connected"); 
        }
      }
    },
  }
});