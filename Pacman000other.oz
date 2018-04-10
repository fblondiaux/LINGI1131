% Pacman000other.oz
functor
import
  Input
   Browser
   OS
export
  portPlayer:StartPlayer
define   
   StartPlayer
   TreatStream
   
in
  % ID is a <pacman> ID
  fun{StartPlayer ID}
    Stream Port
  in
    {NewPort Stream Port}
    thread
       {TreatStream Stream}
    end
    Port
  end

  proc{TreatStream Stream ID Position} % has as many parameters as you want
     case Stream
     of getId(?ID)|T then {Browse 'coucou'} % à changer...
     [] assignSpawn(P)|T then {Browse 'coucou'}
     [] spawn(?ID ?P)|T then {Browse 'coucou'}
     [] move(?ID ?P)|T then {Browse 'coucou'}
     [] bonusSpawn(P)|T then {Browse 'coucou'}
     [] pointSpawn(P)|T then {Browse 'coucou'}
     [] bonusRemoved(P)|T then {Browse 'coucou'}
     [] pointRemoved(P)|T then {Browse 'coucou'}
     [] addPoint(Add ?ID ?NewScore)|T then {Browse 'coucou'}
     [] gotKilled(?ID ?NewLife ?NewScore)|T then {Browse 'coucou'}
     [] ghostPos(ID P)|T then {Browse 'coucou'}
     [] killGhost(IDg ?IDp ?NewScore)|T then {Browse 'coucou'}
     [] deathGhost(ID)|T then {Browse 'coucou'}
     [] setMode(M)|T then {Browse 'coucou'}
     end
  end
end
