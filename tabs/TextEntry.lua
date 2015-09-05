Soda.TextEntry = class(Soda.Frame)

function Soda.TextEntry:init(t)
    t.shape = Soda.RoundedRectangle
    t.label = {text = t.title, x=10, y=0.5} 
    Soda.Frame.init(self, t)
    

    self.offset = vec2(self.label.w + 15, (self.h-self.label.h)*0.5) --bottom corner of text-entry (because left-aligned text needs to be drawn in CORNER mode)
    
    self.characterW = self:getTextSize(Soda.style.textEntry, "a") --width of a character (nb fixed-width font only)
    
        self:inputString(t.default or "")
 
end

function Soda.TextEntry:inputString(txt)
    self.input = {} --table containing each character
    local capacity = (self.w - self.offset.x - 10)//self.characterW --how many characters can fit in the text box
    self.start = math.max(1, txt:len() + 1 - capacity) --the start position of the displayed text, this increases if text width is greater than box width
    for letter in txt:gmatch(".") do --populate input table with contents of txt
        self.input[#self.input+1]=letter
    end
    self.cursor = #self.input+1 --cursor = insertion point for self.input
    self.cursorPos = (self.cursor-self.start) * self.characterW --relative x coords of cursor 
    self.text = table.concat(self.input, "", self.start)
    self.textW = self:getTextSize(Soda.style.textEntry, self.text)
end

function Soda.TextEntry:draw()
    Soda.Frame.draw(self)
    local x = self:left() + self.offset.x
    local y = self:bottom() + self.offset.y
    pushStyle()

    if Soda.keyboardEntity and Soda.keyboardEntity == self then
        local h = 0.25
        if CurrentOrientation == LANDSCAPE_LEFT or CurrentOrientation == LANDSCAPE_RIGHT then h = 0.35 end
        local typewriter = math.max(0, (HEIGHT * h) - y)
        Soda.UIoffset = Soda.UIoffset + (typewriter - Soda.UIoffset) * 0.1
        if (ElapsedTime/0.25)%2<1.3 then
            noStroke()
            fill(0, 201, 255, 200)
            rect(x+self.cursorPos+1,self.y,3,30)
        end
    end
        
    Soda.setStyle(Soda.style.textEntry)
--  Soda.setStyle(self.style.text)

    textAlign(LEFT)
    textMode(CORNER)
    text(self.text, x, y)
     popStyle()
end

function Soda.TextEntry:output()
    return table.concat(self.input)
end

function Soda.TextEntry:touched(t, tpos)
    if self:pointIn(tpos.x, tpos.y) then
        if Soda.keyboardEntity and Soda.keyboardEntity == self then
            --select text, move cursor
            local tp = tpos.x - (self:left() + self.offset.x)
            
          --  if tp<=self.textW then
              --  print("char", self.characterW)
                self.cursor = math.tointeger(self.start + ((math.min(tp, self.textW) + self.characterW * 0.5)//self.characterW) )
            --  print("tp",tp,"cursorPos",self.cursorPos, "cursor", self.cursor)
             self:getCursorPos()
           -- self.cursorPos = self.cursor * self.characterW
          --  end
        else
            if not isKeyboardShowing() then showKeyboard() end
            Soda.keyboardEntity = self
            --[[
            local off = (HEIGHT * 0.4 ) - self.label.y
            if off> 0 then
            tween(0.5, Soda, {UIoffset = off} )
        end
            ]]
        end
        return true

    end
end

function Soda.TextEntry:getCursorPos()
        local beforeCursor = table.concat(self.input, "", self.start, self.cursor-1)
    self.cursorPos = self:getTextSize(Soda.style.textEntry, beforeCursor)
end

function Soda.TextEntry:keyboard(key)
    if key == RETURN then
      --  tween(0.5, Soda, {UIoffset = 0} )
        hideKeyboard()
        Soda.keyboardEntity = nil
    elseif key == BACKSPACE then
        if #self.input>0 and self.cursor>1 then
            table.remove(self.input, self.cursor-1)
            self.cursor = self.cursor - 1    
            self.start = math.max(1, self.start - 1  )    
        end
    else
        table.insert(self.input, self.cursor, key)
        self.cursor = self.cursor + 1
    end
   -- self.text = table.concat(self.input, "", self.start)
    
    if self.textW + self.characterW > self.w - self.offset.x - 10 then
       self.start = self.start + 1 
        
    end
    self.text = table.concat(self.input, "", self.start)
    self.textW = self:getTextSize(Soda.style.textEntry, self.text)
   -- self:getCursorPos()
    self.cursorPos = ((self.cursor - self.start)) * self.characterW
end
