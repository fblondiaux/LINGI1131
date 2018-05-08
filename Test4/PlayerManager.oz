functor
import
   Pacman000random
   Ghost093other
   Pacman093other
   Ghost000random
   Pacman047basic
   Ghost047basic
   Pacman060other
   Ghost060other
   Pacman018random
   Ghost018random

export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   % Kind is one valid name to describe the wanted player, ID is either the <pacman> ID, either the <ghost> ID corresponding to the player
   fun{PlayerGenerator Kind ID}
      case Kind
      of pacman000random then {Pacman000random.portPlayer ID}
      [] pacman093other then {Pacman093other.portPlayer ID}
      [] ghost000random then {Ghost000random.portPlayer ID}
      [] ghost093other then {Ghost093other.portPlayer ID}
      [] pacman047basic then {Pacman047basic.portPlayer ID}
      [] ghost047basic then {Ghost047basic.portPlayer ID}
      [] pacman060other then {Pacman060other.portPlayer ID}
      [] ghost060other then {Ghost060other.portPlayer ID}
      [] ghost018random then {Ghost018random.portPlayer ID}
      [] pacman018random then {Pacman018random.portPlayer ID}
      end
   end
end
