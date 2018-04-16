% Etudiants en binôme
% Audric Deckers - 83861600
% Laurent Ziegler - 03821500 

local
   % Vous pouvez remplacer ce chemin par celui du dossier qui contient ProjectLib.ozf
   % Please replace this path with your own working directory that contains ProjectLib.ozf
   
%   Dossier = {Property.condGet cwdir '/home/admin/Documents/Oz/Project2017'} % Unix example
   Dossier = {Property.condGet cwdir '/Users/audricdeckers/Desktop/Project2017'} % Unix example
   SnakeLib
   
   % Les deux fonctions que vous devez implémenter
   % The two function you have to implement
   Next
   DecodeStrategy
   
   % Hauteur et largeur de la grille
   % Width and height of the grid
   % (1 <= x <= W=22, 1 <= y <= H=22)
   W = 22
   H = 22
   
   Options  
in
   % Merci de conserver cette ligne telle qu'elle.
   % Please do NOT change this line.
   [SnakeLib] = {Link [Dossier#'/'#'ProjectLib.ozf']}
   {Browse SnakeLib.play}
   
%%%%%%%%%%%%%%%%%%%%%%%%
% Your code goes here  %
% Votre code vient ici %
%%%%%%%%%%%%%%%%%%%%%%%%
   local
      % Déclarez vos functions ici
      % Declare your functions here
      X
      Append
      RemoveTheLast
      Move
      Grow
      Revert
      Teleport
      Casa
      Frozen
      DelEffect
      Shrink
   in
      % La fonction qui renvoit les nouveaux attributs du serpent après prise
      % en compte des effets qui l'affectent et de son instruction
      % The function that computes the next attributes of the snake given the effects
      % affecting him as well as the instruction
      % 
      % instruction ::= forward | turn(left) | turn(right)
      % P ::= <integer x such that 1 <= x <= 22>
      % direction ::= north | south | west | east
      % snake ::=  snake(
      %               positions: [
      %                  pos(x:<P> y:<P> to:<direction>) % Head
      %                  ...
      %                  pos(x:<P> y:<P> to:<direction>) % Tail
      %               ]
      %               effects: [grow|revert|teleport(x:<P> y:<P>)|... ...]
      %            )
%%%%%%%%%%%%%%
%%%  NEXT  %%%
%%%%%%%%%%%%%%
      fun {Next Snake Instruction}
	 case Snake.effects
	 of frozen(A)|frozen(B)|T then {Frozen Snake B}
	 [] H|T then
	    case H
	    of nil then {Move Snake Instruction}
	    [] grow then {Next snake(positions:{Grow Snake.positions} effects:{DelEffect grow Snake.effects.2}) Instruction}
	    [] revert then {Next snake(positions:{Revert Snake.positions} effects:{DelEffect revert Snake.effects.2}) Instruction}
	    [] teleport(x:X y:Y) then {Next snake(positions:{Teleport Snake.positions X Y} effects:{DelEffect teleport Snake.effects.2}) Instruction}
	    [] casa(N) then {Casa Snake N}
	    [] frozen(N) then {Frozen Snake N}
	    [] shrink(N) then {Shrink Snake N Instruction}
	    else {Move Snake Instruction}
	    end
	 else {Move Snake Instruction}
	 end
      end
% La fonction qui gère les effets, comme spécifié dans l'énoncé.
%%%%%%%%%%%%%%%%%%%
%%%  DelEffect  %%%
%%%%%%%%%%%%%%%%%%%
      fun {DelEffect Effect LEffect}
	 case Effect
	 of grow then
	    case LEffect of
	       grow|T then {DelEffect Effect T}
	    []H|T then H|{DelEffect Effect T}
	    else nil
	    end	    
	 [] teleport then
	    case LEffect of
	       teleport(x:X y:Y)|T then {DelEffect Effect T}
	    []H|T then H|{DelEffect Effect T}
	       else nil
	    end
	 [] revert then
	    case LEffect of
	       revert|T then {DelEffect Effect T}
	    []H|T then H|{DelEffect Effect T}
	       else nil
	    end
	 [] frozen then
	    case LEffect of
	       frozen(N)|T then {DelEffect Effect T}
	    []H|T then H|{DelEffect Effect T}
	    else nil
	    end
	 [] casa then
	    case LEffect of
	       casa(N)|T then {DelEffect Effect T}
	    []H|T then H|{DelEffect Effect T}
	    else nil
	    end
	 else LEffect
	 end
      end
% La fonction qui retire le dernier élément de la liste passée en argument.
%%%%%%%%%%%%%%%%%%%%%%%%
%%%  RemoveTheLast   %%%
%%%%%%%%%%%%%%%%%%%%%%%%
	 fun {RemoveTheLast H}
	    case H of H|nil then nil
	    [] X|Xr then X|{RemoveTheLast Xr}
	    else nil end
	 end
 % La fonction qui applique une Instruction au serpent sans se préoccuper des effets.
%%%%%%%%%%%%%%%
%%%  MOVE   %%%
%%%%%%%%%%%%%%%
      fun {Move Snake Instruction}
	 %Fait avancer le Snake d'un pas.
	 fun {Forward Snake}
	    case Snake.positions.1.to
	    of north then snake(positions:pos(x:Snake.positions.1.x y:Snake.positions.1.y-1 to:north)|{RemoveTheLast Snake.positions} effects:Snake.effects)
	    [] south then snake(positions:pos(x:Snake.positions.1.x y:Snake.positions.1.y+1 to:south)|{RemoveTheLast Snake.positions} effects:Snake.effects)
	    [] east then snake(positions:pos(x:Snake.positions.1.x+1 y:Snake.positions.1.y to:east)|{RemoveTheLast Snake.positions} effects:Snake.effects)
	    [] west then snake(positions:pos(x:Snake.positions.1.x-1 y:Snake.positions.1.y to:west)|{RemoveTheLast Snake.positions} effects:Snake.effects)
	    else Snake
	    end
	 end
	 
      in
	 case Instruction
	 of turn(right) then
	    if Snake.positions.1.to==east then {Forward snake(positions:pos(x:Snake.positions.1.x y:Snake.positions.1.y to:south)|Snake.positions.2 effects:Snake.effects)}
	    elseif Snake.positions.1.to==south then {Forward snake(positions:pos(x:Snake.positions.1.x y:Snake.positions.1.y to:west)|Snake.positions.2 effects:Snake.effects)}
	    elseif Snake.positions.1.to==west then {Forward snake(positions:pos(x:Snake.positions.1.x y:Snake.positions.1.y to:north)|Snake.positions.2 effects:Snake.effects)}
	    elseif Snake.positions.1.to==north then {Forward snake(positions:pos(x:Snake.positions.1.x y:Snake.positions.1.y to:east)|Snake.positions.2 effects:Snake.effects)}
	    else Snake.positions.1.to = error end
	    
	 []turn(left) then
	    if Snake.positions.1.to==east then {Forward snake(positions:pos(x:Snake.positions.1.x y:Snake.positions.1.y to:north)|Snake.positions.2 effects:Snake.effects)}
	    elseif Snake.positions.1.to==north then {Forward snake(positions:pos(x:Snake.positions.1.x y:Snake.positions.1.y to:west)|Snake.positions.2 effects:Snake.effects)}
	    elseif Snake.positions.1.to==west then {Forward snake(positions:pos(x:Snake.positions.1.x y:Snake.positions.1.y to:south)|Snake.positions.2 effects:Snake.effects)}
	    elseif Snake.positions.1.to==south then {Forward snake(positions:pos(x:Snake.positions.1.x y:Snake.positions.1.y to:east)|Snake.positions.2 effects:Snake.effects)}
	    else Snake.positions.1.to = error end
	    
	 []forward then  {Forward Snake}
	 else Snake end
	 
      end

% La fonction qui applique l'effet "grow" au serpent ; elle renvoit la position du serpent, grandit d'une case.
%%%%%%%%%%%%%%%
%%%  GROW   %%%
%%%%%%%%%%%%%%%
      fun {Grow Pos}
	 case Pos of H|nil then
	    case Pos.1.to
	    of north then  H|pos(x:H.x y:H.y-1 to:north)|nil
	    [] south then H|pos(x:H.x y:H.y+1 to:south)|nil
	    [] east then H|pos(x:H.x+1 y:H.y to:east)|nil
	    [] west then H|pos(x:H.x-1 y:H.y to:west)|nil
	    else Pos
	    end
	 []H|T then H|{Grow T}
	 end
      end
      
% La fonction qui applique l'effet "revert" sur le serpent ; elle renvoit les positions du serpent inversées, en tenant compte des directions.
%%%%%%%%%%%%%%%%
%%%  REVERT  %%%
%%%%%%%%%%%%%%%%
      local
	 fun {DoRevert H T}
	    case H of nil then T
	    [] X|Xr then case X.to
			 of north then {DoRevert Xr pos(x:X.x y:X.y to:south)|T}
			 [] south then {DoRevert Xr pos(x:X.x y:X.y to:north)|T}
			 [] east then {DoRevert Xr pos(x:X.x y:X.y to:west)|T}
			 [] west then {DoRevert Xr pos(x:X.x y:X.y to:east)|T}
			 end
	    end
	 end
      in
	 fun {Revert H} {DoRevert H nil} end
      end
% La fonction qui applique l'effet "teleport" au serpent ; renvoie la position du serpent dont la tête a été téléportée en(PosX,PosY), en tenant compte des directions.
%%%%%%%%%%%%%%%%%%
%%%  TELEPORT  %%%
%%%%%%%%%%%%%%%%%%
      fun {Teleport Pos PosX PosY}
	 case Pos of H|T then pos(x:PosX y:PosY to:H.to)|T
	 else Pos
	 end
      end
      
% La fonction qui applique l'effet "casa" au serpent ; elle applique un effet ou une instruction au hasard.
%%%%%%%%%%%%%%%
%%%  CASA   %%%
%%%%%%%%%%%%%%%
      fun{Casa Snake N}
	 if N==1 then {Move snake(positions:Snake.positions effects:{DelEffect casa Snake.effects.2}) forward}
	 else local I={OS.rand} mod 7 in
		 case I
		 of 0 then {Move snake(positions:Snake.positions effects:casa(N-1)|{DelEffect casa Snake.effects.2}) forward}
		 [] 1 then {Move snake(positions:Snake.positions effects:casa(N-1)|{DelEffect casa Snake.effects.2}) turn(right)}
		 [] 2 then {Move snake(positions:Snake.positions effects:casa(N-1)|{DelEffect casa Snake.effects.2}) turn(left)}
		 [] 3 then {Move snake(positions:{Grow Snake.positions} effects:casa(N-1)|{DelEffect casa Snake.effects.2}) forward}
		 [] 4 then {Move snake(positions:{Revert Snake.positions} effects:casa(N-1)|{DelEffect casa Snake.effects.2}) forward}
		 [] 5 then {Frozen snake(positions:Snake.positions effects:casa(N-1)|{DelEffect casa Snake.effects.2}) 2}
		 [] 6 then {Shrink snake(positions:Snake.positions effects:casa(N-1)|{DelEffect casa Snake.effects.2}) 1 forward}
		 else {Next snake(positions:Snake.positions effects:casa(N-1)|{DelEffect casa Snake.effects.2}) forward}
		 end
	      end
	 end
      end
% La fonction qui applique l'effet "frozen(N)" au serpent ; il ne bouge plus et ne subit plus aucun effet pendant N pas.
%%%%%%%%%%%%%%%%%
%%%  FROZEN   %%%
%%%%%%%%%%%%%%%%%
      fun {Frozen Snake N}
	 if N==1 then {Move snake(positions:Snake.positions effects:{DelEffect frozen Snake.effects.2}) forward}
	 else snake(positions:Snake.positions effects:frozen(N-1)|{DelEffect frozen Snake.effects.2})
	 end
      end
% La fonction qui applique l'effet "shrink(N)" au serpent ; il rétrécit pendant N pas.
%%%%%%%%%%%%%%%%%
%%%  Shrink   %%%
%%%%%%%%%%%%%%%%%
      fun {Shrink Snake N Instruction}
	 if N==1 then {Next snake(positions:{RemoveTheLast Snake.positions} effects:{DelEffect frozen Snake.effects.2}) Instruction}
	 else {Move snake(positions:{RemoveTheLast Snake.positions} effects:shrink(N-1)|{DelEffect frozen Snake.effects.2}) Instruction}
	 end
      end
      % La fonction qui décode la stratégie d'un serpent en une liste de fonctions. Chacune correspond
      % à un instant du jeu et applique l'instruction devant être exécutée à cet instant au snake
      % passé en argument
      % The function that decodes the strategy of a snake into a list of functions. Each corresponds
      % to an instant in the game and should apply the instruction of that instant to the snake
      % passed as argument
      %
      % strategy ::= <instruction> '|' <strategy>
      %            | repeat(<strategy> times:<integer>) '|' <strategy>
      %            | nil
%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  DecodeStrategy   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
      fun {DecodeStrategy Strategy}
	 case Strategy of
	    nil then nil
	 []repeat(D times:V)|T andthen V == 1 then {Append {DecodeStrategy D} {DecodeStrategy T}}
	 []repeat(D times:V)|T then {Append {DecodeStrategy D} {DecodeStrategy repeat(D times:V-1)|T}}
	 []H|T then {Append (fun {$ Snake} {Next Snake H} end)|nil {DecodeStrategy T}}
	 end
      end
      % Additione deux listes l'une à l'autre en commençant par A puis B.
      fun {Append A B}
	 case A
	 of nil then B
	 [] H|T then H|{Append T B}
	 end
      end
      
      % Options
      Options = options(
		   % Fichier contenant le scénario (depuis Dossier)
		   % Path of the scenario (relative to Dossier)
%		   scenario:'scenario_pvp.oz'
	           scenario:'Scenario.oz'
%		   scenario:'scenario_test_casa.oz'
%		   scenario:'scenario_test_frozen.oz'
%		   scenario:'scenario_test_grow.oz'
%	       	   scenario:'scenario_test_revert.oz'
%		   scenario:'scenario_test_moves.oz'
%		   scenario:'scenario_test_teleport.oz'
		   % Visualisation de la partie
		   % Graphical mode
		   debug: true
		   % Instants par seconde, 0 spécifie une exécution pas à pas. (appuyer sur 'Espace' fait avancer le jeu d'un pas)
		   % Steps per second, 0 for step by step. (press 'Space' to go one step further)
		   frameRate: 1
		   )
   end
   
%%%%%%%%%%%
% The end %
%%%%%%%%%%%
   
   local 
      R = {SnakeLib.play Dossier#'/'#Options.scenario Next DecodeStrategy Options}
   in
      {Browse R}
   end
end
