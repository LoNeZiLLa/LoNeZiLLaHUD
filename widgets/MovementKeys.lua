MovementKeys =
  {
  };

registerWidget("MovementKeys");

-------------------------------------------------------------------------
-------------------------------------------------------------------------

function MovementKeys:initialize()
	

end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

function MovementKeys:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  local leftArrowIcon = "internal/ui/icons/keyLeft"
  local upArrowIcon = "internal/ui/icons/keyForward"
  local rightArrowIcon = "internal/ui/icons/keyRight"
  local downArrowIcon = "internal/ui/icons/keyBack"
  local jumpIcon = "internal/ui/icons/keyJump"

  local arrowIconSize = 10
  local arrowIconColor = Color(255,255,255,255)

  if specPl.buttons.left then
    nvgFillColor(arrowIconColor);
    nvgSvg(leftArrowIcon, -30, 0, arrowIconSize);
  end
  if specPl.buttons.forward then
    nvgFillColor(arrowIconColor);
    nvgSvg(upArrowIcon, 0, -30, arrowIconSize);
  end
  if specPl.buttons.right then
    nvgFillColor(arrowIconColor);
    nvgSvg(rightArrowIcon, 30, 0, arrowIconSize);
  end
  if specPl.buttons.back then
    nvgFillColor(arrowIconColor);
    nvgSvg(downArrowIcon, 0, 30, arrowIconSize);
  end
  if specPl.buttons.jump then
    nvgFillColor(arrowIconColor);
    nvgSvg(jumpIcon, 30, 30, arrowIconSize);
  end

end
