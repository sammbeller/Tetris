pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
board = {} -- an array representing the playing field

active_brick = {}	-- the brick over which the player currently has control

turn_counter = 1 -- a value that iterates up to 30 and resets, completing a 'turn'

score = 0 -- current score
debug = -1

-- BRICK SPRITE VALUES
local HOR_LEFT = 1
local HOR_MID = 2
local HOR_RIGHT = 3
local FLAT_TOP = 4
local FLAT_LEFT = 5
local FLAT_RIGHT = 6
local FLAT_BOT = 7
local VERT_TOP = 18
local VERT_MID = 34
local VERT_BOT = 50
local CORNER_TOP_LEFT = 19
local CORNER_TOP_RIGHT = 20
local CORNER_BOT_LEFT = 35
local CORNER_BOT_RIGHT = 36
-- END BRICK SPRITE_VALUES


function _init()
	for i=1,16 do
		board[i] = {}
		for j=1,10 do
			board[i][j] = 0
		end
	end
	active_brick = initialize_right_l()
end

function _update()
	-- read user input
	if btnp(0) and can_move_left(active_brick,board) then
		move_left(active_brick)
	elseif btnp(1) and can_move_right(active_brick,board) then
		move_right(active_brick)
	elseif btnp(2) and active_brick:can_rotate(board) then
		active_brick:rotate()
	elseif btnp(3) then
	 if check_at_rest(active_brick,board) then
			write_to_board(active_brick,board)
			active_brick = initialize_new_brick()
		else
			drop(active_brick,board)
		end
	end		

	turn_counter+=1
	if turn_counter%30 == 0 then
		turn_counter = 0
		if check_at_rest(active_brick,board) then
			write_to_board(active_brick,board)
			active_brick = initialize_new_brick()
		else
			drop(active_brick,board)
		end
	end
 score_board(board)
end


function _draw()
	cls()
	for row=1,#board do
		for col=1,#board[row] do
			draw_square(board[row][col], col, row)
		end
	end
	draw_active(active_brick, board)
	print(score,0,0,11)
	print(debug,0,10,11)
end

function score_board(board)
  for row=1,#board do
    local row_full = true
    for col=1,#board[row] do
      row_full = row_full and board[row][col] != 0
    end
    if row_full then
      score += 1
      clear_row(board,row)
    end
  end
end

-- overwrite all rows from some point with the row above
-- this effectively moves everything down one row and clears
-- the row indicated by row
-- @param board - the board
-- @param row - the index of the row that we're clearing
function clear_row(board, row) 
	i = row
	while i >= 2 do
		for col=1,#board[i] do
   board[i][col] = board[i-1][col]
  end
  i-=1
 end
end


-- draw a single square to the screen
-- @param block_val - an int representing the block to draw
-- @param x - the x coordinate on the board
-- @param 7 - the y coordinate on the board
function draw_square(block_val, x, y)
	if block_val == 0 then
		rectfill((x-1)*8, (y-1)*8,(x*8)-1,(y*8)-1,15)
	else
		spr(block_val,(x-1)*8,(y-1)*8)
	end
end

-- draw the active brick
function draw_active(active_brick, board)
	for brick in all(active_brick) do
		draw_square(brick.type, brick.x, brick.y)
	end
end

-- brick movement

function drop(active_brick, board)
	for brick in all(active_brick) do
		brick.y += 1
	end
end

function move_left(active_brick)
	for brick in all(active_brick) do
		brick.x -= 1
	end
end

function move_right(active_brick)
	for brick in all(active_brick) do
		brick.x += 1
	end
end

-- end brick movement

-- brick movement tests

-- check if a brick should stop falling
-- stops if any part of the brick is at the bottom of the field 
-- or if there is a block in the board beneath it
-- @param active_brick - the currently active brick
-- @param board - the playing field
function check_at_rest(active_brick,board)
	for brick in all(active_brick) do
		if brick.y == 16 or board[brick.y+1][brick.x] != 0 then
			return true
		end
	end
	return false
end

-- theres an indexing bug in here
function can_move_left(active_brick,board)
	for brick in all(active_brick) do
		if brick.x == 1 or board[brick.y][brick.x-1] != 0 then
			return false
		end
	end
	return true
end

function can_move_right(active_brick,board)
	for brick in all(active_brick) do
		if brick.x == 10 or board[brick.y][brick.x+1] != 0 then
			return false
		end
	end
	return true
end

-- end brick movement tests

function write_to_board(active_brick,board)
	for brick in all(active_brick) do
		board[brick.y][brick.x] = brick.type
	end
end

-- brick
-- indices 1-4 with type, x, y
-- can_rotate function
-- rotate function

-- initialization methods for brick shapes
function initialize_new_brick()
  local brick_num = flr(rnd(7)) + 1
  debug = brick_num
  if brick_num == 1 then
    return initialize_left_l()
  elseif brick_num == 2 then
    return initialize_right_l()
  elseif brick_num == 3 then
    return initialize_long()
  elseif brick_num == 4 then
    return initialize_t()
  elseif brick_num == 5 then
    return initialize_square()
  elseif brick_num == 6 then
    return initialize_left_bend()
  elseif brick_num == 7 then
    return initialize_right_bend()
  end
end

function initialize_long()

  local HORIZONTAL= 0
  local VERTICAL = 1

	local long_brick = {}
	long_brick.state = HORIZONTAL

	function long_brick:rotate()
		if self.state == HORIZONTAL then
			self[1].type = VERT_TOP
			self[1].x += 1
			self[1].y -= 1
			self[2].type = VERT_MID
			self[3].type = VERT_MID
			self[3].x -= 1
			self[3].y += 1
			self[4].type = VERT_BOT
			self[4].x -= 2
			self[4].y += 2
			self.state = VERTICAL
		elseif self.state == VERTICAL then
			self[1].type = HOR_LEFT
			self[1].x -= 1
			self[1].y += 1
			self[2].type = HOR_MID
			self[3].type = HOR_MID
			self[3].x += 1
			self[3].y -= 1
      self[4].type = HOR_RIGHT
      self[4].x += 2
      self[4].y -= 2
			self.state = HORIZONTAL
		end
  end

  function long_brick:can_rotate(board)
    if self.state == HORIZONTAL then
      -- Is this brick at the top or bottom of the board?
      if self[1].y == 1 or self[1].y == 16 then
        return false
      end
      for brick in all(self) do
        -- are there any bricks on board immediately above or below this?
        if board[brick.x][brick.y-1] != 0 or board[brick.x][brick.y+1] != 0 then
          return false
        end
      end
      return true
    elseif self.state == VERTICAL then
      if self[1].x == 1 then
        -- see if it can move right and do so if possible
        if can_move_right(self,board) 
          and board[self[2].x+3][self[2].y] == 0 then
            move_right(self)
            return true
        else
          return false
        end
      -- if this brick is on the right side of the board
      -- set everything manually and return false
      -- TODO brick 3 not rendering right?
      elseif self[1].x == 10 then
        if board[self[2].x-1][self[2].y] == 0
          and board[self[2].x-2][self[2].y] == 0
          and board[self[2].x-3][self[2].y] == 0 then
            self.state = HORIZONTAL
            self[1].type = HOR_LEFT
            self[1].x = 7
            self[1].y = self[2].y
            self[2].type = HOR_MID
            self[2].x = 8
            self[2].type = HOR_MID
            self[3].x = 9
            self[3].y = self[2].y
            self[4].type = HOR_RIGHT
            self[4].x = 10
            self[4].y = self[2].y
            return false -- LIES
        else
            return false
        end
      end

      if board[self[2].x-1][self[2].y] != 0
        or board[self[2].x+1][self[2].y] != 0
        or board[self[2].x+2][self[2].y] != 0 then
          return false
      end
      -- if this brick is on the left side of the board
      return true
    end
  end
	long_brick[1] = {}
	long_brick[1].type = HOR_LEFT
	long_brick[1].x = 4
	long_brick[1].y = 1
	long_brick[2] = {}
	long_brick[2].type = HOR_MID
	long_brick[2].x = 5
	long_brick[2].y = 1
	long_brick[3] = {}
	long_brick[3].type = HOR_MID
	long_brick[3].x = 6
	long_brick[3].y = 1
	long_brick[4] = {}
	long_brick[4].type = HOR_RIGHT
	long_brick[4].x = 7
	long_brick[4].y = 1
  return long_brick
end

-- Makes one of these guys
--   _____
-- 1|_ 2 _|3
--    |_| 
--     4
-- The numbers indicate the indices of the respective bricks
function initialize_t()
  -- STATE
  --   _____
  -- 1|_ 2 _|3
  --    |_| 
  --     4
  local POINT_DOWN = 0
  --     _
  --   _| |1
  -- 4|_  |2
  --    |_|3
  local POINT_LEFT = 1
  --    _4
  --  _| |_
  -- |_____|
  --  3 2 1 
  local POINT_UP = 2
  --   _
  -- 3| |_
  -- 2|  _|4
  -- 1|_|
  local POINT_RIGHT = 3

  local t_brick = {}
  function t_brick:rotate()
    if self.state == POINT_DOWN then
      self.state = POINT_LEFT
      self[1].type = VERT_TOP
      self[1].x += 1
      self[1].y -= 1
      self[2].type = FLAT_RIGHT
      self[3].type = VERT_BOT
      self[3].x -= 1
      self[3].y += 1
      self[4].type = HOR_LEFT
      self[4].x -= 1
      self[4].y -= 1
    elseif self.state == POINT_LEFT then
      self.state = POINT_UP
      self[1].type = HOR_RIGHT
      self[1].x += 1
      self[1].y += 1
      self[2].type = FLAT_BOT
      self[3].type = HOR_LEFT
      self[3].x -= 1
      self[3].y -= 1
      self[4].type = VERT_TOP
      self[4].x += 1
      self[4].y -= 1
    elseif self.state == POINT_UP then
      self.state = POINT_RIGHT
      self[1].type = VERT_BOT
      self[1].x -= 1
      self[1].y += 1
      self[2].type = FLAT_LEFT
      self[3].type = VERT_TOP
      self[3].x += 1
      self[3].y -= 1
      self[4].type = HOR_RIGHT
      self[4].x += 1
      self[4].y += 1
    elseif self.state == POINT_RIGHT then
      self.state = POINT_DOWN
      self[1].type = HOR_LEFT
      self[1].x -= 1
      self[1].y -= 1
      self[2].type = FLAT_TOP
      self[3].type = HOR_RIGHT
      self[3].x += 1
      self[3].y += 1
      self[4].type = VERT_BOT
      self[4].x -= 1
      self[4].y += 1
    end
  end

  function t_brick:can_rotate(board)
    if self.state == POINT_DOWN then
      if board[self[2].x][self[2].y-1] != 0 then
        return false;
      else
        return true;
      end
    elseif self.state == POINT_LEFT then
      if self[2].x == 10 then -- special case for this orientation against right side of board
        if can_move_left(self,board)
          and board[self[1].x-1][self[1].y] == 0 then
            move_left(self)
            return true
        else
            return false
        end
      end
      if board[self[2].x+1][self[2].y] != 0 then
        return false
      else
        return true
      end
      --if board[self[2].x][self[2].y]
    elseif self.state == POINT_UP then
      if board[self[2].x][self[2].y+1] != 0 then
        return false
      else
        return true
      end
    elseif self.state == POINT_RIGHT then
      if self[2].x == 1 then --special case for this orientation against left side of board
        if can_move_right
          and board[self[1].x+1][self[1].y] == 0 then
            move_right(self)
            return true
        else
            return false
        end
      end
      if board[self[2].x-1][self[2].y] != 0 then
        return false
      else
        return true
      end
    end   
  end

  t_brick.state = POINT_DOWN
	t_brick[1] = {}
	t_brick[1].type = 1
	t_brick[1].x = 4
	t_brick[1].y = 1
	t_brick[2] = {}
	t_brick[2].type = 4
	t_brick[2].x = 5
	t_brick[2].y = 1
	t_brick[3] = {}
	t_brick[3].type = 3
	t_brick[3].x = 6
	t_brick[3].y = 1
	t_brick[4] = {}
	t_brick[4].type = 50
	t_brick[4].x = 5
	t_brick[4].y = 2
  return t_brick
end

function initialize_square()
 
  local square_brick = {}
  square_brick[1] = {}
  square_brick[1].type = CORNER_TOP_LEFT
  square_brick[1].x = 5
  square_brick[1].y = 1
  square_brick[2] = {}
  square_brick[2].type = CORNER_TOP_RIGHT
  square_brick[2].x = 6
  square_brick[2].y = 1
  square_brick[3] = {}
  square_brick[3].type = CORNER_BOT_LEFT
  square_brick[3].x = 5
  square_brick[3].y = 2
  square_brick[4] = {}
  square_brick[4].type = CORNER_BOT_RIGHT
  square_brick[4].x = 6
  square_brick[4].y = 2

  -- noop
  function square_brick:rotate()
    return self
  end

  function square_brick:can_rotate(board)
    return false
  end
  return square_brick
end

function initialize_left_bend()
 
  -- STATE
  local HORIZONTAL = 0
  local VERTICAL = 1

  local left_bend = {}
  left_bend.state = HORIZONTAL
  left_bend[1] = {}
  left_bend[1].type = HOR_LEFT
  left_bend[1].x = 5
  left_bend[1].y = 1
  left_bend[2] = {}
  left_bend[2].type = CORNER_TOP_RIGHT
  left_bend[2].x = 6
  left_bend[2].y = 1
  left_bend[3] = {}
  left_bend[3].type = CORNER_BOT_LEFT
  left_bend[3].x = 6
  left_bend[3].y = 2
  left_bend[4] = {}
  left_bend[4].type = HOR_RIGHT
  left_bend[4].x = 7
  left_bend[4].y = 2

  function left_bend:rotate()
    if self.state == HORIZONTAL then
      self.state = VERTICAL
      self[1].type = VERT_TOP
      self[1].x += 1
      self[1].y -= 1
      self[2].type = CORNER_BOT_RIGHT
      self[3].type = CORNER_TOP_LEFT
      self[3].x -= 1
      self[3].y -= 1
      self[4].type = VERT_BOT
      self[4].x -= 2
    elseif self.state == VERTICAL then
      self.state = HORIZONTAL
      self[1].type = HOR_LEFT
      self[1].x -= 1
      self[1].y += 1
      self[2].type = CORNER_TOP_RIGHT
      self[3].type = CORNER_BOT_LEFT
      self[3].x += 1
      self[3].y += 1
      self[4].type = HOR_RIGHT
      self[4].x += 2
    end
  end  

  function left_bend:can_rotate(board)
    if self.state == HORIZONTAL then
      if board[self[2].x][self[2].y-1] != 0
        or board[self[2].x-1][self[2].y+1] != 0 then
          return false
      else
          return true
      end
    elseif self.state == VERTICAL then
      if self[2].x == 10 then
        if can_move_left(self,board) then
          move_left(self)
          return true
        else
          return false
        end
      end
      if board[self[2].x][self[2].y+1] != 0
        or board[self[2].x+1][self[2].y+1] != 0 then
          return false
      else
          return true
      end
    end
  end

  return left_bend
end

function initialize_right_bend()

  -- STATE
  local HORIZONTAL = 0
  local VERTICAL = 1

  local right_bend = {}
  right_bend.state = HORIZONTAL
  right_bend[1] = {}  
  right_bend[1].type = HOR_RIGHT
  right_bend[1].x = 7
  right_bend[1].y = 1
  right_bend[2] = {}
  right_bend[2].type = CORNER_TOP_LEFT
  right_bend[2].x = 6
  right_bend[2].y = 1
  right_bend[3] = {}
  right_bend[3].type = CORNER_BOT_RIGHT
  right_bend[3].x = 6
  right_bend[3].y = 2
  right_bend[4] = {}
  right_bend[4].type = HOR_LEFT
  right_bend[4].x = 5
  right_bend[4].y = 2

  function right_bend:rotate()
    if self.state == HORIZONTAL then
      self.state = VERTICAL
      self[1].type = VERT_TOP
      self[1].x -= 1
      self[1].y -= 1
      self[2].type = CORNER_BOT_LEFT
      self[3].type = CORNER_TOP_RIGHT
      self[3].x += 1
      self[3].y -= 1
      self[4].type = VERT_BOT
      self[4].x += 2
    elseif self.state == VERTICAL then
      self.state = HORIZONTAL
      self[1].type = HOR_RIGHT
      self[1].x += 1
      self[1].y += 1
      self[2].type = CORNER_TOP_LEFT
      self[3].type = CORNER_BOT_RIGHT
      self[3].x -= 1
      self[3].y += 1
      self[4].type = HOR_LEFT
      self[4].x -= 2
    end
  end

  function right_bend:can_rotate(board)
    if self.state == HORIZONTAL then
      if board[self[2].x][self[2].y-1] != 0
        or board[self[2].x+1][self[2].y+1] != 0 then
          return false
      else
          return true
      end
    elseif self.state == VERTICAL then
      if self[2].x == 1 then
        if can_move_right(self,board) then
          move_right(self)
          return true
        else
          return false
        end
      end
      if board[self[2].x][self[2].y+1] != 0
        or board[self[2].x-1][self[2].y+1] != 0 then
          return false
      else
          return true
      end
    end
  end

  return right_bend
end

function initialize_left_l()
  -- STATE
  --    _
  --   |4|
  --  _|3|
  -- |___|
  --  1 2 
  local POINT_UP = 0
  --   _
  -- 1| |___
  --  |_____|
  --   2 3 4
  local POINT_RIGHT = 1
  --    ___
  --  2|  _|1
  --   | |3
  --   |_|4
  local POINT_DOWN = 2
  --  4 3 2
  --  _____
  -- |___  | 
  --     |_|
  --      1
  local POINT_LEFT = 3

  local left_l = {}
  left_l.state = POINT_UP
  left_l[1] = {}
  left_l[1].type = HOR_LEFT
  left_l[1].x = 4
  left_l[1].y = 3
  left_l[2] = {}
  left_l[2].type = CORNER_BOT_RIGHT
  left_l[2].x = 5
  left_l[2].y = 3
  left_l[3] = {}
  left_l[3].type = VERT_MID
  left_l[3].x = 5
  left_l[3].y = 2
  left_l[4] = {}
  left_l[4].type = VERT_TOP
  left_l[4].x = 5
  left_l[4].y = 1

  -- TODO This code is breaking sometimes after rotating to POINT_RIGHT
  function left_l:rotate()
    if self.state == POINT_UP then
      self.state = POINT_RIGHT
      self[1].type = VERT_TOP
      self[1].x += 1
      self[1].y -= 1
      self[2].type = CORNER_BOT_LEFT
      self[3].type = HOR_MID
      self[3].x += 1
      self[3].y += 1
      self[4].type = HOR_RIGHT
      self[4].x += 2
      self[4].y += 2
    elseif self.state == POINT_RIGHT then
      self.state = POINT_DOWN
      self[1].type = HOR_RIGHT
      self[1].x += 1
      self[1].y += 1
      self[2].type = CORNER_TOP_LEFT
      self[3].type = VERT_MID
      self[3].x -= 1
      self[3].y += 1
      self[4].type = VERT_BOT
      self[4].x -= 2
      self[4].y += 2
    elseif self.state == POINT_DOWN then
      self.state = POINT_LEFT
      self[1].type = VERT_BOT
      self[1].x -= 1
      self[1].y += 1
      self[2].type = CORNER_TOP_RIGHT
      self[3].type = HOR_MID
      self[3].x -= 1
      self[3].y -= 1
      self[4].type = HOR_LEFT
      self[4].x -= 2
      self[4].y -= 2
    elseif self.state == POINT_LEFT then
      self.state = POINT_UP
      self[1].type = HOR_LEFT
      self[1].x -= 1
      self[1].y -= 1
      self[2].type = CORNER_BOT_RIGHT
      self[3].type = VERT_MID
      self[3].x += 1
      self[3].y -= 1
      self[4].type = VERT_TOP
      self[4].x += 2
      self[4].y -= 2
    end
  end

  function left_l:can_rotate(board)
    if self.state == POINT_UP then
    if self[2].x == 10 then
      if board[self[2].x-2][self[2].y] == 0
        and board[self[2].x-2][self[2].y-1] == 0 then
          -- move the piece and return false
          self.state = POINT_RIGHT
          self[1].type = VERT_TOP
          self[1].x -= 1
          self[1].y -= 1
          self[2].type = CORNER_BOT_LEFT
          self[2].x -= 2
          self[3].type = HOR_MID
          self[3].x -= 1
          self[3].y += 1
          self[4].type = HOR_RIGHT
          self[4].y += 2
          return false
      else
          return false
      end
    end
    if self[2].x == 9 then
      if can_move_left(self,board) then
        move_left(self)
        return true
      else
        return false
      end
    end
    if board[self[2].x+1][self[2].y] != 0
      or board[self[2].x+2][self[2].y] != 0 then
        return false
    else
        return true
    end
    elseif self.state == POINT_RIGHT then
      if board[self[2].x][self[2].y+1] != 0
        or board[self[2].x][self[2].y+2] != 0 then
          return false
      else
          return true
      end
    elseif self.state == POINT_DOWN then
      if self[2].x == 1 then
        if board[self[2].x+2][self[2].y] == 0
          and board[self[2].x+2][self[2].y+1] == 0 then
            -- move the piece and return false
            self.state = POINT_LEFT
            self[1].type = VERT_DOWN
            self[1].x += 1
            self[1].y += 1
            self[2].type = CORNER_TOP_RIGHT
            self[2].x += 2
            self[3].type = HOR_MID
            self[3].x += 1
            self[3].y -= 1
            self[4].type = HOR_LEFT
            self[4].y -= 2
            return false
        else
            return false
        end
      end
      if self[2].x == 2 then
        if can_move_right(self,board) then
          move_right(self)
          return true
        else
          return false
        end
      end
      if board[self[2].x-1][self[2].y] != 0
        or board[self[2].x-2][self[2].y] != 0 then
          return false
      else
          return true
      end
    elseif self.state == POINT_LEFT then
      if board[self[2].x][self[2].y-1] != 0
        or board[self[2].x][self[2].y-2] != 0 then
          return false
      else
          return true
      end
    end
  end

  return left_l
end


function initialize_right_l()
  -- STATE
  --  _
  -- |4|
  -- |3|_
  -- |___|  
  --  2 1
  local POINT_UP = 0
  --  2 3 4
  --  _____
  -- |  ___| 
  -- |_| 
  --  1    
  local POINT_RIGHT = 1
  --   ___
  -- 1|_  |2
  --    | |3
  --    |_|4
  local POINT_DOWN = 2
  --       _
  --   ___| |1
  --  |_____|
  --   4 3 2
  local POINT_LEFT = 3

  local right_l = {}
  right_l.state = POINT_UP
  right_l[1] = {}
  right_l[1].type = HOR_RIGHT
  right_l[1].x = 6
  right_l[1].y = 3
  right_l[2] = {}
  right_l[2].type = CORNER_BOT_LEFT
  right_l[2].x = 5
  right_l[2].y = 3
  right_l[3] = {}
  right_l[3].type = VERT_MID
  right_l[3].x = 5
  right_l[3].y = 2
  right_l[4] = {}
  right_l[4].type = VERT_TOP
  right_l[4].x = 5
  right_l[4].y = 1

  function right_l:rotate()
    if self.state == POINT_UP then
      self.state = POINT_RIGHT
      self[1].type = VERT_BOT
      self[1].x -= 1
      self[1].y += 1
      self[2].type = CORNER_TOP_LEFT
      self[3].type = HOR_MID
      self[3].x += 1
      self[3].y += 1
      self[4].type = HOR_RIGHT
      self[4].x += 2
      self[4].y += 2
    elseif self.state == POINT_RIGHT then
      self.state = POINT_DOWN
      self[1].type = HOR_LEFT
      self[1].x -= 1
      self[1].y -= 1
      self[2].type = CORNER_TOP_RIGHT
      self[3].type = VERT_MID
      self[3].x -= 1
      self[3].y += 1
      self[4].type = VERT_BOT
      self[4].x -= 2
      self[4].y += 2
    elseif self.state == POINT_DOWN then
      self.state = POINT_LEFT
      self[1].type = VERT_TOP
      self[1].x += 1
      self[1].y -= 1
      self[2].type = CORNER_BOT_RIGHT
      self[3].type = HOR_MID
      self[3].x -= 1
      self[3].y -= 1
      self[4].type = HOR_LEFT
      self[4].x -= 2
      self[4].y -= 2
    elseif self.state == POINT_LEFT then
      self.state = POINT_UP
      self[1].type = HOR_RIGHT
      self[1].x += 1
      self[1].y += 1
      self[2].type = CORNER_BOT_LEFT
      self[3].type = VERT_MID
      self[3].x += 1
      self[3].y -= 1
      self[4].type = VERT_TOP
      self[4].x += 2
      self[4].y -= 2
    end
  end

  function right_l:can_rotate(board)
    if self.state == POINT_UP then
      if self[2].x == 9 then
        if can_move_left(self,board) then
          move_left(self)
          return true
        else
          return false
        end
      end
      if board[self[2].x][self[2].y+1] != 0
        or board[self[2].x+2][self[2].y] != 0 then
          return false
      else
          return true
      end
    elseif self.state == POINT_RIGHT then
      if board[self[2].x-1][self[2].y] != 0
        or board[self[2].x][self[2].y+2] != 0 then
          return false
      else
          return true
      end
    elseif self.state == POINT_DOWN then
      if self[2].x == 2 then
        if can_move_right(self,board) then
          move_right(self)
          return true
        else
          return false
        end
      end
      if board[self[2].x][self[2].y-1] != 0
        or board[self[2].x-2][self[2].y] != 0 then
          return false
      else
          return true
      end
    elseif self.state == POINT_LEFT then
      if board[self[2].x+1][self[2].y] != 0
        or board[self[2].x][self[2].y-2] != 0 then
          return false
      else
          return true
      end
    end
  end

  return right_l
end

__gfx__
00000000cccccccccccccccccccccccccccccccccddddddddddddddcdddddddd0000000000000000000000000000000000000000000000000000000000000000
00000000cddddddddddddddddddddddcddddddddcddddddddddddddcdddddddd0000000000000000000000000000000000000000000000000000000000000000
00700700cddddddddddddddddddddddcddddddddcddddddddddddddcdddddddd0000000000000000000000000000000000000000000000000000000000000000
00077000cddddddddddddddddddddddcddddddddcddddddddddddddcdddddddd0000000000000000000000000000000000000000000000000000000000000000
00077000cddddddddddddddddddddddcddddddddcddddddddddddddcdddddddd0000000000000000000000000000000000000000000000000000000000000000
00700700cddddddddddddddddddddddcddddddddcddddddddddddddcdddddddd0000000000000000000000000000000000000000000000000000000000000000
00000000cddddddddddddddddddddddcddddddddcddddddddddddddcdddddddd0000000000000000000000000000000000000000000000000000000000000000
00000000ccccccccccccccccccccccccddddddddcddddddddddddddccccccccc0000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccddddddddddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cddddddc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

