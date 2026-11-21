function love.load()
    math.randomseed(os.time())
    height = love.graphics.getHeight()
    width = love.graphics.getWidth()

    -- player dimensions
    playerDimension = {
        YSize = height / 10,
    }
    playerDimension.XSize = playerDimension.YSize / 4

    -- players
    player1 = {
        positionX = width / 100,
        positionY = height / 50,
    }
    player2 = {
        positionX = width / 1.01 - playerDimension.XSize,
        positionY = height / 50,
    }

    -- ball
    ball = {
        side = height / 40,
        startingPositionX = width  / 2,
        startingPositionY = height / 2,
        velocityX = math.random(-3, 3),
        velocityY = math.random(-3, 3),
    }
    
    ball.actualPositionX = ball.startingPositionX
    ball.actualPositionY = ball.startingPositionY

    if ball.velocityX == 0 then ball.velocityX = 2 end
    if ball.velocityY == 0 then ball.velocityY = 2 end
    
    -- counters
    counters = {
    player1 = 0,
    player2 = 0,
    -- size
    -- position
    }
    font = love.graphics.newFont(48)
end

local function clamp(value, lowerBound, higherBound)
    return math.max(lowerBound, math.min(higherBound, value))
end

-- Reflect off top/bottom walls
local function bounceTopBottom()
    if ball.actualPositionY < 0 then 
        ball.actualPositionY = 0
        ball.velocityY = -ball.velocityY
    elseif ball.actualPositionY + ball.side > height then
        ball.actualPositionY = height - ball.side
        ball.velocityY = -ball.velocityY
    end
end

-- Reflect off a paddle (vertical surface -> flip velocityX)
local function bouncePaddle(paddle, isLeft)
    local px, py = paddle.positionX, paddle.positionY
    local pw, ph = playerDimension.XSize, playerDimension.YSize

    if ball.actualPositionX < px + pw and
       ball.actualPositionX + ball.side > px and
       ball.actualPositionY < py + ph and
       ball.actualPositionY + ball.side > py then

        ball.velocityX = -ball.velocityX
        -- push the ball out so it doesnt retrigger in the next frame
        if isLeft then
            ball.actualPositionX = px + pw
        else
            ball.actualPositionX = px - ball.side
        end
    end
end

-- Puts the ball back at center and relaunches it
-- serveRight = true -> ball starts moving right (toward player2)
-- serveRight = false -> ball starts moving left (toward player1)
local function resetBall(serveRight)
    ball.actualPositionX = ball.startingPositionX
    ball.actualPositionY = ball.startingPositionY

    -- Random launch velocity
    ball.velocityX = math.random(-3, 3)
    ball.velocityY = math.random(-3, 3)
    if ball.velocityX == 0 then ball.velocityX = 2 end
    if ball.velocityY == 0 then ball.velocityY = 2 end

    -- force the horizontal direction to point at the loser
    if serveRight and ball.velocityX < 0 then
        ball.velocityX = -ball.velocityX
    elseif not serveRight and ball.velocityX > 0 then
        ball.velocityX = -ball.velocityX
    end
end

local function checkScore()
    -- ball fully past the LEFT edge -> player2 scored
    if ball.actualPositionX + ball.side < 0 then
        counters.player2 = counters.player2 + 1
        resetBall(false)   -- serve left, toward player1 (the loser)
    end

    -- ball fully past the RIGHT edge -> player1 scored
    if ball.actualPositionX > width then
        counters.player1 = counters.player1 + 1
        resetBall(true)    -- serve right, toward player2 (the loser)
    end
end

function love.resize(w, h)
    width, height = w, h

    -- resizes the player and ball sizes relative to screen size
    playerDimension.YSize = height / 10
    playerDimension.XSize = playerDimension.YSize / 4
    ball.side = height / 40

    -- repositions the player and ball relative to screen size
    player1.positionX = width / 100
    player1.positionY = height / 50
    player2.positionX = width / 1.01 - playerDimension.XSize
    player2.positionY = height / 50
    
    -- counter resize and reposition
end

function love.update(dt)
    ball.actualPositionX = ball.actualPositionX + ball.velocityX
    ball.actualPositionY = ball.actualPositionY + ball.velocityY

    bounceTopBottom()
    checkScore()
    bouncePaddle(player1, true)
    bouncePaddle(player2, false)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "up" then player1.positionY = player1.positionY - 30 end
    if key == "down" then player1.positionY = player1.positionY + 30 end
    if key == "w" then player2.positionY = player2.positionY - 30 end
    if key == "s" then player2.positionY = player2.positionY + 30 end
end

function love.draw()
    love.graphics.rectangle("fill", player1.positionX, player1.positionY, playerDimension.XSize, playerDimension.YSize)

    love.graphics.rectangle("fill", player2.positionX, player2.positionY, playerDimension.XSize, playerDimension.YSize)

    love.graphics.rectangle("fill", ball.actualPositionX, ball.actualPositionY, ball.side, ball.side)

    -- collision bars
    love.graphics.rectangle("fill", 0, 0, width, 1) -- top
    love.graphics.rectangle("fill", 0, height - 1, width, 1) -- bottom
    love.graphics.rectangle("fill", 0, 0, 1, height) -- left
    love.graphics.rectangle("fill", width - 1, 0, 1, height) -- right
    
    love.graphics.setFont(font)

    -- player1's score ends 40px left of center; player2's starts 40px right of center
    love.graphics.printf(tostring(counters.player1), 0, 20, width / 2 - 40, "right")

    love.graphics.printf(tostring(counters.player2), width / 2 + 40, 20, width / 2 - 40, "left")
                         
    -- dashed line
    local dashHeight, dashGap = 20, 20
    local dashY = 80 -- start below the score
    while dashY < height - dashHeight do
        love.graphics.rectangle("fill", width / 2 - 2, dashY, 4, dashHeight)
        dashY = dashY + dashHeight + dashGap
    end
end
