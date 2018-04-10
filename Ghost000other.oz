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
   % ID is a <ghost> ID
   fun{StartPlayer ID}
    Stream Port
   in
      {NewPort Stream Port}
      thread
	 {TreatStream Stream}
      end
      Port
   end
   
   
   
   proc{TreatStream Stream} % has as many parameters as you want
      case Stream
      of getId(?ID)|T then {Browse 'coucou'} % à changer
      [] move(?ID ?P)|T then {Browse 'coucou'}
      [] gotKilled()|T then {Browse 'coucou'}
      [] pacmanPos(ID P)|T then {Browse 'coucou'}
      [] killPacman(ID)|T then {Browse 'coucou'}
      [] deathPacman(ID)|T then {Browse 'coucou'}
      [] setMode(M)|T then {Browse 'coucou'}	 
      end
   end
end
