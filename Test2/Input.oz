functor
export
   isTurnByTurn:IsTurnByTurn
   nRow:NRow
   nColumn:NColumn
   map:Map
   respawnTimePoint:RespawnTimePoint
   respawnTimeBonus:RespawnTimeBonus
   respawnTimePacman:RespawnTimePacman
   respawnTimeGhost:RespawnTimeGhost
   rewardPoint:RewardPoint
   rewardKill:RewardKill
   penalityKill:PenalityKill
   nbLives:NbLives
   huntTime:HuntTime
   nbPacman:NbPacman
   pacman:Pacman
   colorPacman:ColorPacman
   nbGhost:NbGhost
   ghost:Ghost
   colorGhost:ColorGhost
   thinkMin:ThinkMin
   thinkMax:ThinkMax
define
   IsTurnByTurn
   NRow
   NColumn
   Map
   RespawnTimePoint
   RespawnTimeBonus
   RespawnTimePacman
   RespawnTimeGhost
   RewardPoint
   RewardKill
   PenalityKill
   NbLives
   HuntTime
   NbPacman
   Pacman
   ColorPacman
   NbGhost
   Ghost
   ColorGhost
   ThinkMin
   ThinkMax
in

%%%% Style of game %%%%

   %IsTurnByTurn = true
   IsTurnByTurn = false

%%%% Description of the map %%%%

   NRow = 8
   NColumn = 8
   Map = [[0 4 1 0 0 0 4 0]
     [0 1 1 0 1 1 1 0]
     [0 0 0 0 0 0 0 0]
     [0 2 0 0 1 1 0 3]
     [0 0 1 0 4 1 0 0]
     [0 0 0 0 0 0 0 0]
     [3 0 1 1 0 0 2 0]
     [0 0 1 4 0 0 0 0]]


%%%% Respawn times %%%%

   RespawnTimePoint = 10
   RespawnTimeBonus = 15
   RespawnTimePacman = 5
   RespawnTimeGhost = 5





%%%% Rewards and penalities %%%%

   RewardPoint = 1
   RewardKill = 5
   PenalityKill = 5

%%%%

   NbLives = 2
   HuntTime = 10

%%%% Players description %%%%


  NbPacman = 1
   Pacman = [pacman093other]
   ColorPacman = [yellow]

   NbGhost = 1
   Ghost = [ghost093other]
   ColorGhost =[green]% black red white]

%%%% Thinking parameters (only in simultaneous) %%%%

   ThinkMin = 50
   ThinkMax = 300

end
