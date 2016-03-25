
# encoding: utf-8

# класс для работы с ячейками 
class Cell 

  attr_accessor :pos_x, :pos_y, :is_bomb, :is_opened, :is_marked, :button, :label   # даем доступ к информации о ячейке

  def initialize(pos_x, pos_y, bomb)                                                # при создании новой ячейки определяем:
    @pos_x    = pos_x                                                               # позиция ячейки по горизонтали
    @pos_y    = pos_y                                                               # позиция ячейки по вертикали
    @is_bomb  = bomb                                                                # бомба или нет
    @is_opened   = false                                                            # ячейка не открыта
    @is_marked   = false                                                            # флажок не поставлен
    @button                                                                         # ссылка на визуальное отображение ячейки 
    @label                                                                          # ссылка на подпись о количестве бомб вокруг
  end
end

# класс для работы с полем игры
class Field

  attr_accessor :bombs_to_place                                                     # в дальнейшем понадобится доступ к количеству бомб, чтобы вывести в окно

  def initialize(size_x, size_y, bombs_to_place, app)                               # инициализируем и передаем контекст графического приложения
    @size_x      = size_x                                                           # размер поля по горизонтали
    @size_y      = size_y                                                           # размер поля по вертикали
    @bombs_to_place = bombs_to_place                                                # количество бомб на поле
    @num_cells = @size_x * @size_y - @bombs_to_place                                # считаем количество ячеек, которые НЕ бомбы
    @opened_cells = 0                                                               # счетчик, показывающий, сколько ячеек уже открыто
    @field = Array.new                                                              # создаем массив с ячейками
    @bombs = Array.new                                                              # создаем массив с бомбами
    @marked = 0                                                                     # счетчик поставленных флажков
    @app = app                                                                      # сохраняем контекст приложения в переменную
  end

  # переключает, установлен, или нет, флаг в определенной ячейке
  def toggle_mark(cell)
    unless cell.is_opened                                                           # на открытые ячейки флаги не ставим, поэтому не обрабатываем
      if cell.is_marked                                                             # если флаг стоит
        cell.button.style(fill:  "#000000")                                         # меняем стиль ячейки на обычный черный
        cell.is_marked = false                                                      # меняем свойство ячейки 
        @marked -= 1                                                                # уменьшаем счетчик флажков
      else                                            
        cell.button.style(fill:  "#49ff00")                                         # если флаг не стоит
        cell.is_marked = true                                                       # меняем свойство ячейки
        @marked += 1                                                                # увеличиваем счетчик флажков
      end
      if @marked == @bombs_to_place                                                 # если количество бомб равно количеству флажков
        n = @bombs.select { |c| c.is_marked == false }                              # выбираем, есть ли бомбы, на которых не стоят флажки 
        @app.you_win if n.count == 0                                                # если нет, то выводим поздравление с выигрышем
      end
    end
  end

  # открывает ячейку на поле
  def open(cell)                
    unless cell.is_opened                                                            # если уже открыта, то не обрабатывается
      if cell.is_bomb                                                                # если в ячейке бомба
        cell.is_opened = true                                                        # ставим метку об открытости
        cell.button.style(fill:  "#ff0000")                                          # меняем цвет на красный
        cell.label.text = "B!"                                                       # выводим значок бомбы
        @app.game_over                                                               # игра окончена
      else                                                                           # иначе
        cell.is_opened = true                                                        # помечаем открытой
        @cells_around  = cells_around(cell)                                          # выбираем соседние ячейки
        baround = bombs_around(cell)                                                 # считаем, сколько бомб вокруг
        if  baround > 0                                                              # если есть
          cell.button.style(fill:  "#face21")                                        # закрашиваем желтым
          cell.label.text = baround.to_s                                             # и выводим количество
        else
          cell.button.style(fill:  "#ffffff")                                        # если бомб вокруг нет
          @cells_around.each { |c| open(c) unless c.is_opened }                      # рекурсивно открываем все окружающие ячейки
        end
      @opened_cells += 1                                                             # увеличиваем счетчик открытых ячеек
      @app.you_win if @opened_cells == @num_cells                                    # если количество открытых равно количеству ячеек без бомб, выводим поздравление с победой
      end
    end
  end

  # проверяет, сколько бомб воркруг определенной ячейки
  def bombs_around(cell)
    @baround = 0                                                                      # обнуляем количество бомб вокруг
    @caround = cells_around(cell)                                                     # берет список ячеек вокруг начальной
    @caround.each {|c| @baround += 1 if c.is_bomb }                                   # проходим соседей, если бомба, то прибавляем единицу к счетчику
    @baround                                                                          # возвращаем значение
  end

  # открывает все поле в случае выигрыша или проигрыша
  def show_field
    @field.each do |b|                                                                # каждую ячейку
      unless b.is_opened                                                              # кроме открытых
        if b.is_bomb                                                                  # если бомба
          b.is_opened = true                                                          # ставим метку об открытости
          b.button.style(fill:  "#ff0000")                                            # ставим стиль
          b.label.text = "B!"                                                         # и значок бомбы
        else                                                                          # если не бомба
          b.is_opened = true                                                          # ставим метку об открытости
          @cells_around  = cells_around(b)                                            # выбираем соседние ячейки
          baround = bombs_around(b)                                                   # считаем бомбы вокруг
          if  baround > 0                                                             # если есть
            b.button.style(fill:  "#face21")                                          # закрашиваем желтым
            b.label.text = baround.to_s                                               # показываем количество
          else                                                                        # если бомб нет
            b.button.style(fill:  "#ffffff")                                          # закрашиваем белым
          end
        end
      end
    end    
  end

  # возвращает массив ячеек вокруг определенной
  def cells_around(cell)                                 
    @cells = Array.new                                                                # пока массив с соседними ячейками пустой
    [-1, 0, 1].each do |n|                                                            # указываем смещение по горизонтали                                     
      [-1, 0, 1].each do |m|                                                          # и вертикали
        @field.each do |c|                                                            # проходим по всем ячейкам
          @cells.push(c) if (c.pos_x == cell.pos_x+n) and (c.pos_y == cell.pos_y+m)   # и выбираем те, у которых нужные нам координаты
        end                         
      end
    end   
    @cells                                                                            # возвращаем массив
  end

# генерирует игровое поле
  def build_field 
    @size_xy      = @size_x * @size_y                                                 # количество ячеек на поле
    @delta        = 0                                                                 # пройдено ячеек генератором
    @bombs_placed = 0                                                                 # установлено бомб
    @size_x.times do |x|                                                              # проходим по горизонтали
      @size_y.times do |y|                                                            # и вертикали
        bomb = is_bomb?(((@bombs_to_place - @bombs_placed)*100)/(@size_xy - @delta))  # случайно генерируем бомба это, или нет (кол-во бомб, которые осталось уствновить)*100 и / на количество ячеек которые осталось пройти 
        @delta += 1                                                                   # увеличиваем счетчик пройденных ячеек
        @bombs_placed = @bombs_placed + 1 if bomb                                     # увеличиваем счетчик установленных бомб
        n = Cell.new(x, y, bomb)                                                      # создаем объект ячейки
        @field.push(n)                                                                # добавляем к игровому полю
        @bombs.push(n) if bomb                                                        # добавляем в список бомб
      end
    end
    @field                                                                            # возвращаем массив игрового поля
  end

# основываясь на вероятности выпадения, вычисляем, является ли ячейка бомбой
  def is_bomb?(chance)           
    @rgen = Random.new                                                                # создаем генератор псевдослучайных чисел
    @num = @rgen.rand(1...100)                                                        # генерируем число от 1 до 100
    if @num < (chance)                                                                # если полученное от генератора число меньше, чем вероятность выпадения бомбы в процентах
      true                                                                            # возвращаем бомбу 
    else                                                                              # иначе
      false                                                                           # возвращаем не бомбу
    end
  end
end

# графическая часть приложения 
Shoes.app(title: "Sapper", width: 1000, height: 700) do                               # главный объект фреймворка Shoes
  @now_mark = false                                                                   # по умолчанию устанавливаем режим выбора
  keypress do |k|                                                                     # отлавливаем нажатия кнопок клавиатуры
    if k == " "                                                                       # и если это пробел
      if @now_mark                                                                    # меняем режим на ФЛАГ или ВЫБОР, в зависимости от того, какой сейчас
        @now_mark = false                                                             #
        @cap_mode.text = "Now: PICK"                                                  # также, меняем надпись в форме  
      else                                                                            #
        @now_mark = true                                                              #
        @cap_mode.text = "Now: FLAG"                                                  #
      end                                                                               
    end   
  end
  @field_view = flow do                                                               # разметка окна
    stack do 
      @cap_mode = para "Now: PICK"
      @cap_bombs = para "Bombs placed: " 
    end
    @control_view = stack do 
      @button_new_game_1 = button "Beginner" do                                       # кнопки, которые вызывают функцию новой игры с различными параметрами
        self.new_game(9, 9, 10)                                                       # в зависимости от уровня сложности
      end
      @button_new_game_2 = button "Standard" do
        self.new_game(16, 16, 40)
      end
      @button_new_game_3 = button "Advanced" do
        self.new_game(30, 16, 99)
      end
    end
  end

  # начинает новую игру
  def new_game(x, y, bombs)                                                           
    @field_object = Field.new(x, y, bombs, self)                                     # создаем объект поля 
    @game_field = @field_object.build_field                                          # генерируем игровое поле
    @cap_bombs.text = "Bombs placed: " + @field_object.bombs_to_place.to_s           # указываем в форме, сколько бомб на поле
    @game_stack.clear() unless @game_stack == nil                                    # очищаем контейнер с визуальным изображением поля на форме
    @game_stack = stack do                                                          
      @game_field.each do |cell|                                                     # создаем для каждой ячейки
        @cbutton = rect(32 * cell.pos_x, 32 * cell.pos_y, 30, 30)                    # квадратик
        @clabel  = para "", left: ((32 * cell.pos_x) + 2), top: (170 + 32 * cell.pos_y) # и метку, на которой указано количество бомб вокруг
        @cbutton.click do                                                            # при нажатии на квадрат
          if @now_mark                                                               # в режиме ФЛАГ
            @field_object.toggle_mark(cell)                                          # вызываем обработку установки флага, класса Field
          else                                                                       # в режиме ВЫБОР
            @field_object.open(cell)                                                 # вызываем обработку открытия 
          end
        end
        cell.button = @cbutton                                                       # помещаем визуальные объекты в 
        cell.label  = @clabel                                                        # объекты класса Cell
      end
    end
  end

  def game_over                                                                     # если игра проиграна
    alert("You are lose!")                                                          # выводим табличку
    @field_object.show_field                                                        # и открываем поле
  end
  def you_win                                                                       # если игра выиграна
    alert("Wow! You are win!")                                                      # выводим табличку
    @field_object.show_field                                                        # и открываем поле
  end
end

