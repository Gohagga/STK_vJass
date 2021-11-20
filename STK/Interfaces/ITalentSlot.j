library STKITalentSlot

    interface ITalentSlot

        method GetButtonFrame takes nothing returns framehandle

        method SetVisible takes boolean isVisible returns nothing

        method GetTalent takes nothing returns STKTalent_Talent

        method SetTalent takes STKTalent_Talent talent returns nothing

        method GetRank takes nothing returns integer

        method SetRank takes integer rank returns nothing

        method GetIndex takes nothing returns integer

        method GetWatcher takes nothing returns player

        method SetWatcher takes player watcher returns nothing

        method GetState takes nothing returns integer

        method SetState takes integer state returns nothing

        method GetErrorText takes nothing returns string

        method SetErrorText takes string text returns nothing

        method MoveTo takes framepointtype point, framehandle relative, framepointtype relativePoint, real x, real y, real linkWidth, real linkHeight returns nothing

        method RenderLinks takes string dependencyLeft, string dependencyUp, string dependencyRight, string dependencyDown returns nothing

    endinterface

endlibrary