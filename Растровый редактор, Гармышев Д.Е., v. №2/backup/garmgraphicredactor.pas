{
Изменения в программе:
+ возможность рисовать смайлики
+ смена размера ластика/кисти/линии/смайлика с помощью колёсиков мыши.
+ возможность рисовать резиновые фигуры
+ рисование клавишами работает только в режиме - 3, рисование начинается
от курсора мыши
}

unit GarmGraphicRedactor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ActnList,
  Menus, ColorBox, ComCtrls, StdCtrls, LCLType, Spin, Types;

type

  { TFormGarmDraw }

  TFormGarmDraw = class(TForm)
    CBtnGarmColorBrush: TColorButton;
    BtnGarmChangeDrawErase: TButton;
    CBtnGarmColorBackground: TColorButton;
    BtnGarmClearBackground: TButton;
    GarmMainMenu: TMainMenu;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MainMenu1: TMainMenu;
    MIGarmBitDraw: TMenuItem;
    MIGarmSmileDraw: TMenuItem;
    MIGarmGeometryDraw: TMenuItem;
    MIGarmGeometryCircleDraw: TMenuItem;
    MIGarmGeometryEllipseDraw: TMenuItem;
    MIGarmGeometrySquareDraw: TMenuItem;
    MIGarmGeometryRectangleDraw: TMenuItem;
    MIGarmSelectedOption: TMenuItem;
    MIGarmPointsDraw: TMenuItem;
    MIGarmLinesDraw: TMenuItem;
    MenuItem3: TMenuItem;
    MIGarmSimpleDraw: TMenuItem;
    MIGarmSimpleErase: TMenuItem;
    Panel1: TPanel;
    SEGarmBrushSize: TSpinEdit;
    procedure BtnGarmChangeDrawEraseClick(Sender: TObject);
    procedure BtnGarmClearBackgroundClick(Sender: TObject);
    procedure CBtnGarmColorBackgroundColorChanged(Sender: TObject);
    procedure GarmKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GarmMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GarmMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GarmKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GarmMouseEnter(Sender: TObject);
    procedure GarmMouseLeave(Sender: TObject);
    procedure GarmFormCreate(Sender: TObject);
    procedure GarmMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GarmMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure GarmMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MIGarmGeometryCircleDrawClick(Sender: TObject);
    procedure MIGarmGeometryEllipseDrawClick(Sender: TObject);
    procedure MIGarmGeometryRectangleDrawClick(Sender: TObject);
    procedure MIGarmGeometrySquareDrawClick(Sender: TObject);
    procedure MIGarmPointsDrawClick(Sender: TObject);
    procedure MIGarmLinesDrawClick(Sender: TObject);
    procedure MIGarmSimpleDrawClick(Sender: TObject);
    procedure MIGarmSimpleEraseClick(Sender: TObject);
    procedure MIGarmSmileDrawClick(Sender: TObject);
    procedure pDrawSmile(lX,lY,size: integer);
  private

  public

  end;

var
  FormGarmDraw: TFormGarmDraw;
  //Переменные необходимые для регулирования режимов рисования
  bDrawOn, bEraseOn, bDrLine, bDrawSmile: boolean;
  r, t: integer; //Радиус и толщина кисти
  drawType: integer; //В главном меню выбираем что именно мы хотим нарисовать
  //Начальные и конечные точки рисования (x1 и y1 нужны для рисования линиями)
  X0,Y0: integer;
  X1,Y1: integer;

  btnUpPressed, btnDownPressed, btnLeftPressed, btnRightPressed, drawByKeys:boolean;

implementation





{ TFormGarmDraw }


//В данной процедуре происходит начальная инициализация переменных
procedure TFormGarmDraw.GarmFormCreate(Sender: TObject);
begin
 drawType := 1; //Начинаем с режима рисования точек
 r:= 15; // Радиус ластика.
 t:= 8; // Толщина линии при рисовании.
 bDrawOn:=False;
 bEraseOn:=False;
 bDrLine:=True;
 Canvas.Pen.Mode:=pmCopy;
 Canvas.Pen.Width:=t;
 FormGarmDraw.Color := CBtnGarmColorBackground.ButtonColor;
 MIGarmSelectedOption.Caption := 'Рисование точками'; {В конце главного меню
 можно увидеть опцию, в которой отображается текущий инструмент рисования}

 btnUpPressed := false;
 btnDownPressed := false;
 btnLeftPressed := false;
 btnRightPressed := false;
 drawByKeys := false;

 bDrawSmile := true;

 Randomize;
end;

//Процедура срабатывает когда мышка уходит за пределы области рисования
//Учитываются режимы стирания и рисования смалика
procedure TFormGarmDraw.GarmMouseLeave(Sender: TObject);
begin
 if (drawType = 3) and bEraseOn then
 begin
      Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r);
 end;

 if (drawType = 9) and bEraseOn then
 begin
      pDrawSmile(x0, y0, SEGarmBrushSize.value);
 end;

end;

//Процедура срабатывает когда мышка входит в пределы области рисования
//Учитываются режимы стирания и рисования смалика
procedure TFormGarmDraw.GarmMouseEnter(Sender: TObject);
begin
   if (drawType = 3) and bEraseOn then
   begin
      Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r);
      end;

   if (drawType = 9) and bEraseOn then
   begin
      pDrawSmile(x0, y0, SEGarmBrushSize.value);
 end;
end;

//Кнопка для быстрого переключения режима рисования/стирания
procedure TFormGarmDraw.BtnGarmChangeDrawEraseClick(Sender: TObject);
begin
  bEraseOn:= not bEraseOn;
  bDrLine:= not bDrLine;

  if bEraseOn then
     begin
     BtnGarmChangeDrawErase.Caption:='Стираем';
     Canvas.Pen.Width:=2; // Толщина контура ластика.
     Canvas.Pen.Mode:=pmNotXor;
     Canvas.Brush.Color:=clGray; // Цвет ластика при движении.
     Canvas.Pen.Color:=clBlue; // Цвет контура ластика.
    end;

    if bDrLine then
    begin
    BtnGarmChangeDrawErase.Caption:='Рисуем';
    Canvas.Pen.Width:=t;
    Canvas.Pen.Mode:=pmCopy;
    Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor; // Цвет при рисовании линий.
    end;
end;


//Кнопка для очистки фона
{
Выставляем для кисти и карандаша все нужные хар-ки
и заполняем всю область прямоугольником
Тем самым мы очищаем наш фон
}
procedure TFormGarmDraw.BtnGarmClearBackgroundClick(Sender: TObject);
begin
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := CBtnGarmColorBackground.ButtonColor;
  Canvas.Pen.Color := CBtnGarmColorBackground.ButtonColor;
  Canvas.FillRect(Canvas.ClipRect);

end;

{Фон меняется сразу после выбора цвета}
procedure TFormGarmDraw.CBtnGarmColorBackgroundColorChanged(Sender: TObject);
begin
  FormGarmDraw.Color := CBtnGarmColorBackground.ButtonColor;
end;


{Ниже представлены процедуры изменения размера радиуса посредством движения
колёсика мыши. Вверх - увеличить, вниз - уменьшить.

Обнаружилось следующее - если во время смены радиуса у нас включен режим стирания
- остаётся след от ластика, поэтому - мы сначала рисуем ластик с текущим размером,
чтобы не оставался след "старого ластика", изменяем радиус, и уже после этого
рисуем "новый ластик", чтобы так-же не оставался след от него}
procedure TFormGarmDraw.GarmMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

  if drawType = 3 then
  begin

       if bEraseOn then
       begin
         Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r);
       end;

       SEGarmBrushSize.value := SEGarmBrushSize.value + 1;
       r := SEGarmBrushSize.value;

       if bEraseOn then
       begin
         Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r);
       end;
  end;

  //Та же процедура для смайлика
  if drawType = 9 then
  begin
       pDrawSmile(x0, y0, SEGarmBrushSize.value);

       SEGarmBrushSize.value := SEGarmBrushSize.value + 1;
       r := SEGarmBrushSize.value;

       pDrawSmile(x0, y0, SEGarmBrushSize.value);
  end;

  {Это условие помогает избежать "артефактов" во время рисования
  линии или фигуры}
  if not bDrawOn and not bEraseOn then
  begin

    SEGarmBrushSize.value := SEGarmBrushSize.value + 1;
       r := SEGarmBrushSize.value;

  end;

end;

//Повторяется то-же самое что и в "WheelUp", но радиус уже уменьшается
procedure TFormGarmDraw.GarmMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin


  if drawType = 3 then
  begin

       if bEraseOn then
       begin
         Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r);
       end;

       SEGarmBrushSize.value := SEGarmBrushSize.value - 1;
       r := SEGarmBrushSize.value;

       if bEraseOn then
       begin
         Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r);
       end;
  end;

  if drawType = 9 then
  begin
       Canvas.Pen.Mode := pmNotXor;
       pDrawSmile(x0, y0, SEGarmBrushSize.value);

       SEGarmBrushSize.value := SEGarmBrushSize.value - 1;
       r := SEGarmBrushSize.value;

       pDrawSmile(x0, y0, SEGarmBrushSize.value);


  end;

  if not bDrawOn and not bEraseOn then
  begin

    SEGarmBrushSize.value := SEGarmBrushSize.value - 1;
       r := SEGarmBrushSize.value;

  end;


end;


//Отслеживаем нажатия клавиш, для рисования клавишами
//Срабатывает только когда включён режим обычного рисования
//Пока у нас нажата кнопка - двигаемся в нужном направлении
procedure TFormGarmDraw.GarmKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin


if (drawType = 3) and not bEraseOn then
begin

     drawByKeys := true;
     FormGarmDraw.SetFocus;

     //Вверх
     if Key = VK_UP then
     begin
     btnUpPressed := true;
     if btnUpPressed then
     begin
     Canvas.Pen.Width:=SEGarmBrushSize.value;
     Canvas.moveTo(x0, y0);
     y0 := y0 - 1;
     Canvas.lineTo(x0, y0);
     end;
     end

     //Вниз
     else if Key = VK_DOWN then
     begin
     btnDownPressed := true;
     if btnDownPressed then
     begin
     Canvas.Pen.Width:=SEGarmBrushSize.value;
     Canvas.moveTo(x0, y0);
     y0 := y0 + 1;
     Canvas.lineTo(x0, y0);
     end;
     end

     //Вправо
     else if Key = VK_RIGHT then
     begin
     btnRightPressed := true;
     if btnRightPressed then
     begin
     Canvas.Pen.Width:=SEGarmBrushSize.value;
     Canvas.moveTo(x0, y0);
     x0 := x0 + 1;
     Canvas.lineTo(x0, y0);
     end;
     end

     //Влево
     else if Key = VK_LEFT then
     begin
     btnLeftPressed := true;
     if btnLeftPressed then
     begin
     Canvas.Pen.Width:=SEGarmBrushSize.value;
     Canvas.moveTo(x0, y0);
     x0 := x0 - 1;
     Canvas.lineTo(x0, y0);
     end;
     end;
end;

end;

//При отпускании нажатой клавиши - перестаём рисовать
procedure TFormGarmDraw.GarmKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if Key = VK_UP then
  begin
  btnUpPressed := false;
  drawByKeys := false;
  end

  else if Key = VK_DOWN then
  begin
  btnDownPressed := false;
  drawByKeys := false;
  end

  else if Key = VK_RIGHT then
  begin
  btnRightPressed := false;
  drawByKeys := false;
  end

  else if Key = VK_LEFT then
  begin
  btnLeftPressed := false;
  drawByKeys := false;
  end;

end;




{Процедура срабатывает на нажатие кнопки мыши, и уже в зависимости от выбранного
режима рисования - происходят необходимые действия}
procedure TFormGarmDraw.GarmMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var fillStyle: integer;
begin
     bDrawOn := true; //Говорим всей программе, что кнопка для рисования нажата
     case drawType of
     1: begin
     {При одиночном нажатии (первом нажатии), рисуем один большой круг
     с определённым радиусом, рандомным цветом и заливкой}
     r := 30;
     fillStyle:=Random(8);
     case fillStyle of
     1: Canvas.Brush.Style := bsSolid;
     2: Canvas.Brush.Style := bsClear;
     3: Canvas.Brush.Style := bsBDiagonal;
     4: Canvas.Brush.Style := bsFDiagonal;
     5: Canvas.Brush.Style := bsCross;
     6: Canvas.Brush.Style := bsDiagCross;
     7: Canvas.Brush.Style := bsHorizontal;
     8: Canvas.Brush.Style := bsVertical;
     end;
     Canvas.Brush.Color:=Random(clNavy-X+Y);
     Canvas.Ellipse(X-r,Y-r,X+r,Y+r);
     end;

     2: begin
     {При первом нажатии, выставляем все нужные параметры для
     рисования линий}
     Canvas.Pen.Mode:=pmNotXor;
     Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Width:=SEGarmBrushSize.value;
     Canvas.moveTo(X, Y);
     X0 := X; Y0 := Y;
     X1 := X; Y1 := Y;
     end;

     3: begin
     if bEraseOn then
     begin // Начинаем стирание.
     // 7. Здесь установки для ластика при стирании.
     // При движении пока ничего не видно, но по щелчку
     // будет отрисован ластик с контуром.
     Canvas.Pen.Mode := pmCopy; // Для старта режима инверсного рисования
     Canvas.Pen.Color := FormGarmDraw.Color;
     Canvas.Brush.Color := Canvas.Pen.Color; // сначала надо стереть
     Canvas.Brush.Style := bsSolid;
     Canvas.Ellipse(x-r,y-r,x+r,y+r); // ластиком в текущем месте.
     // Теперь тоже, но в инверсном режиме.
     Canvas.Pen.Mode:=pmNotXor;
     Canvas.Brush.Color:=clGray;
     Canvas.Pen.Color:=clBlue;
     Canvas.Ellipse(x-r,y-r,x+r,y+r);
     end;
     end;

     4: begin
     {При первом нажатии, выставляем все нужные параметры для
     рисования фигуры}
     Canvas.Brush.Style := bsSolid;
     Canvas.Pen.Mode:=pmNotXor;
     Canvas.Brush.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.moveTo(X, Y);
     X0 := X; Y0 := Y;
     X1 := X; Y1 := Y;
     r := x0 - x;
     end;

     5: begin
     {При первом нажатии, выставляем все нужные параметры для
     рисования фигуры}
     Canvas.Brush.Style := bsSolid;
     Canvas.Pen.Mode:=pmNotXor;
     Canvas.Brush.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.moveTo(X, Y);
     X0 := X; Y0 := Y;
     X1 := X; Y1 := Y;
     end;

     6: begin
     {При первом нажатии, выставляем все нужные параметры для
     рисования фигуры}
     Canvas.Brush.Style := bsSolid;
     Canvas.Pen.Mode:=pmNotXor;
     Canvas.Brush.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.moveTo(X, Y);
     X0 := X; Y0 := Y;
     X1 := X; Y1 := Y;
     r := x0 - x;
     end;

     7: begin
     {При первом нажатии, выставляем все нужные параметры для
     рисования фигуры}
     Canvas.Brush.Style := bsSolid;
     Canvas.Pen.Mode:=pmNotXor;
     Canvas.Brush.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.moveTo(X, Y);
     X0 := X; Y0 := Y;
     X1 := X; Y1 := Y;
     end;

     end;
end;

{
Процедура срабатывает при движении мыши по области рисования
}
procedure TFormGarmDraw.GarmMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var fillStyle: integer;
begin
     case drawType of
     1: begin
     if(bDrawOn) then
     begin
     r:=Random(30);
     Canvas.Brush.Color:=Random(clNavy-X+Y);
     Canvas.Pen.Color:=Random(clNavy-X+Y);
     Canvas.Pen.Width := Random(8);
     fillStyle:=Random(8);
     case fillStyle of
     1: Canvas.Brush.Style := bsSolid;
     2: Canvas.Brush.Style := bsClear;
     3: Canvas.Brush.Style := bsBDiagonal;
     4: Canvas.Brush.Style := bsFDiagonal;
     5: Canvas.Brush.Style := bsCross;
     6: Canvas.Brush.Style := bsDiagCross;
     7: Canvas.Brush.Style := bsHorizontal;
     8: Canvas.Brush.Style := bsVertical;
     end;
     Canvas.Ellipse(X-r,Y-r,X+r,Y+r);
     end;
     end;

     2:begin
     if(bDrawOn) then
     begin
     Canvas.Pen.Mode:=pmNotXor;
     Canvas.Pen.Width := SEGarmBrushSize.value;;
     Canvas.MoveTo(X0,Y0);
     Canvas.LineTo(X1,Y1);
     X1:=X; Y1:=Y;
     Canvas.MoveTo(X0, Y0);
     Canvas.LineTo(X,Y);
     end;
     end;

     3: begin
     if not drawByKeys then
     begin
     {Если мы не стираем и не рисуем, сохраняем последнюю позицию мыши на холсте
     В некоторых случаях это помогает избежать ситуации когда при начале рисования рисуется линия
     из другого конца холста}
     if (not bDrawOn and bdrLine) or (not bDrawOn and bEraseOn) then
     Canvas.moveTo(x, y);

     //Срабатывает когда мы просто рисуем
     if bDrawOn and bdrLine then
     begin
     Canvas.Pen.Width:=SEGarmBrushSize.value; //Ширина линий при рисовании.
     Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor; // Цвет линий при рисовании.
     Canvas.LineTo(x,y); //Рисуем линию.
     end;

     {Срабатывает когда включён режим стирания но не нажата клавиша мыши.
     В этом случае мы двигаем ластик без стирания}
     if bEraseOn and not bDrawOn then
     begin
     Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r); // Удаляем на старом месте.
     Canvas.Ellipse(x-r,y-r,x+r,y+r); // Показываем на текущем месте.
     x0:=x;y0:=y; // Запомним текущее место (станет старым).
     end;

     {Срабатывает когда включён режим стирания, и нажата кнопка стирания
     т.е. стираем наши рисунки}
     if bEraseOn and bDrawOn then
     begin
     Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r);
     //Выставляем свойства для стирания
     Canvas.Pen.Mode:=pmCopy;
     Canvas.Pen.Color:=FormGarmDraw.Color;
     Canvas.Brush.Color:=Canvas.Pen.Color;
     Canvas.Brush.Style:=bsSolid;
     Canvas.Ellipse(x-r,y-r,x+r,y+r); // Стираем в текущем месте
     // Опять установки для пермещения видимого ластика
     Canvas.Pen.Mode:=pmNotXor;
     Canvas.Brush.Color:=clGray;
     Canvas.Pen.Color:=clBlue;
     Canvas.Ellipse(x-r,y-r,x+r,y+r); // показываем на текущем месте
     x0:=x;y0:=y; // Запоминаем текущее место
     end;
     x0:=x;y0:=y;
     end;
     end;

     4: begin
     if bDrawOn then
     begin
     Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r);
     r := x0 - x;
     Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r);
     end;
     end;

     5: begin
     if bDrawOn then
     begin
     Canvas.Ellipse(x0,y0,x1,y1);
     x1 := x; y1 := y;
     Canvas.Ellipse(x0, y0, x1, y1);
     end;
     end;

     6: begin
     if bDrawOn then
     begin
     Canvas.Rectangle(x0-r,y0-r,x0+r,y0+r);
     r := x0 - x;
     Canvas.Rectangle(x0-r,y0-r,x0+r,y0+r);
     end;
     end;

     7: begin
     if bDrawOn then
     begin
     Canvas.Rectangle(x0,y0,x1,y1);
     x1 := x; y1 := y;
     Canvas.Rectangle(x0,y0,x1,y1);
     end;
     end;

     9: begin
     Canvas.MoveTo(x, y);
     if bEraseOn and not bDrawOn then
     begin
     pDrawSmile(x0, y0, SEGarmBrushSize.value); // Показываем на текущем месте.
     x0:=x;y0:=y;
     pDrawSmile(x, y, SEGarmBrushSize.value);
     end;
     end;

     end;
end;

//Процедура срабатывает при отпускании клавиши мыши
procedure TFormGarmDraw.GarmMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     bDrawOn := false; //Сразу говорим всей программе что была отпущена клавиша

     case drawType of
     2: begin
     {Для режима рисования линиями
     Выставляем режим "copy", для того чтобы у нас
     нарисовалась линия не в режиме notxor с инверсией цветов,
     а для того чтобы появилась полноценная линия}
     Canvas.Pen.Mode:=pmCopy;
     Canvas.MoveTo(X0,Y0);
     Canvas.LineTo(X1,Y1);
     end;

     3: begin
     //Выставляем нужные настройки для ластика и кисти
     if bEraseOn then Canvas.Pen.Width:=2;
     if bDrLine then Canvas.Pen.Width:=t;
     end;

     4: begin
     Canvas.Pen.Mode:=pmCopy;
     Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r);
     end;

     5: begin
     Canvas.Pen.Mode:=pmCopy;
     Canvas.Ellipse(x0,y0,x,y);
     end;

     6: begin
     Canvas.Pen.Mode:=pmCopy;
     Canvas.Rectangle(x0-r,y0-r,x0+r,y0+r);
     end;

     7: begin
     Canvas.Pen.Mode:=pmCopy;
     Canvas.Rectangle(x0,y0,x,y);
     end;

     9: begin
     bDrawSmile := not bDrawSmile;
     if bDrawSmile then
     begin
     Canvas.Pen.Mode := pmCopy;
     pDrawSmile(x0, y0, SEGarmBrushSize.value);
     Canvas.Pen.Mode := pmNotXor;
     pDrawSmile(x0, y0, SEGarmBrushSize.value);
     end;
     end;

     end;
end;



{Следующие процедуры реагируют на выборы разных элемнтов меню
Если выбираем режим рисования точками - выставляеются одни сва-ва
Для других режимов - другие}

//Рисование точками
procedure TFormGarmDraw.MIGarmPointsDrawClick(Sender: TObject);
begin
   bEraseOn := False;
     drawType := 1;
     r:=60;
     Canvas.Pen.Mode := pmCopy;

     BtnGarmChangeDrawErase.enabled := false; {Эта строка есть и в следующей процедуре
     Она нужна для того, чтобы мы отключали кнопку смены режима "рисование/стирание"
     и избегали непредвиденных ситуаций}

     MIGarmSelectedOption.Caption := 'Рисование точками';

end;

//Рисование линиями
procedure TFormGarmDraw.MIGarmLinesDrawClick(Sender: TObject);
begin
     bEraseOn := False;
     drawType := 2;
     Canvas.Brush.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Style:=psSolid;
     Canvas.Pen.Width:=SEGarmBrushSize.value;

     BtnGarmChangeDrawErase.enabled := false;

     MIGarmSelectedOption.Caption := 'Рисование линиями';
end;

//Режим рисования
procedure TFormGarmDraw.MIGarmSimpleDrawClick(Sender: TObject);
begin
     drawType := 3;
     BEraseOn:=False;
     bDrLine := True;

     Canvas.Pen.Width:=SEGarmBrushSize.value;
     Canvas.Pen.Mode:=pmCopy;
     Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor;
     BtnGarmChangeDrawErase.enabled := true; //Тут наоборот, включаем нужную кнопку
     BtnGarmChangeDrawErase.caption := 'Рисуем';

     MIGarmSelectedOption.Caption := 'Простое рисование';
end;

//Режим стирания
procedure TFormGarmDraw.MIGarmSimpleEraseClick(Sender: TObject);
begin
     drawType := 3;
     BEraseOn:=True;
     bDrLine := false;

     Canvas.Pen.Width:=2; // Толщина контура ластика.
     Canvas.Pen.Mode:=pmNotXor;
     Canvas.Brush.Color:=clGray; // Цвет ластика при движении.
     Canvas.Pen.Color:=clBlue;
     BtnGarmChangeDrawErase.enabled := true;
     BtnGarmChangeDrawErase.caption := 'Стираем';
     MIGarmSelectedOption.Caption := 'Режим ластика';

end;


//Рисование "резиновых" окружностей
procedure TFormGarmDraw.MIGarmGeometryCircleDrawClick(Sender: TObject);
begin

     bEraseOn := False;
     drawType := 4;
     Canvas.Brush.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Style:=psSolid;
     Canvas.Pen.Width := 1;

     BtnGarmChangeDrawErase.enabled := false;

     MIGarmSelectedOption.Caption := 'Рисование резиновых окружностей';


end;

//Рисование "резиновых" эллипсов
procedure TFormGarmDraw.MIGarmGeometryEllipseDrawClick(Sender: TObject);
begin
     bEraseOn := False;
     drawType := 5;
     Canvas.Brush.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Style:=psSolid;
     Canvas.Pen.Width := 1;

     BtnGarmChangeDrawErase.enabled := false;

     MIGarmSelectedOption.Caption := 'Рисование резиновых эллипсов';

end;

//Рисование "резиновых" квадратов
procedure TFormGarmDraw.MIGarmGeometrySquareDrawClick(Sender: TObject);
begin
     bEraseOn := False;
     drawType := 6;
     Canvas.Brush.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Style:=psSolid;
     Canvas.Pen.Width := 1;

     BtnGarmChangeDrawErase.enabled := false;

     MIGarmSelectedOption.Caption := 'Рисование резиновых квадратов';

end;

//Рисование "резиновых" прямоугольников
procedure TFormGarmDraw.MIGarmGeometryRectangleDrawClick(Sender: TObject);
begin
     bEraseOn := False;
     drawType := 7;
     Canvas.Brush.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Color:=CBtnGarmColorBrush.ButtonColor;
     Canvas.Pen.Style:=psSolid;
     Canvas.Pen.Width := 1;

     BtnGarmChangeDrawErase.enabled := false;

     MIGarmSelectedOption.Caption := 'Рисование резиновых прямоугольников';

end;

//Рисование смайлика
procedure TFormGarmDraw.MIGarmSmileDrawClick(Sender: TObject);
begin

     drawType := 9;

     BEraseOn:=True;
     bDrLine := false;

     Canvas.Brush.Style := bsSolid;
     Canvas.Pen.Mode:=pmNotXor;
     BtnGarmChangeDrawErase.enabled := false;
     MIGarmSelectedOption.Caption := 'Рисование смайлика';

end;

procedure TFormGarmDraw.pDrawSmile(lX,lY,size: integer);
begin

  if bDrawOn then Canvas.Pen.Mode := pmCopy;
     //Выствляем настройки для рисования тело
     Canvas.Brush.Color := clYellow;
     Canvas.Pen.Color := clBlack;
     Canvas.Pen.Width := 5;

     //Тело
     Canvas.Ellipse(lX - size, lY - size, lX + size, lY + size);

     //Выставляем настройки для рисования глаза
     Canvas.Brush.Color := clBlack;

     //Левый глаз
     Canvas.Ellipse(
     lX - (size div 3) - (size div 4),
     lY - (size div 3) - (size div 4),
     lX + (size div 4)- (size div 2),
     lY + (size div 3) - (size div 4)
     );

     //Правый глаз
     Canvas.Ellipse(lX - (size div 3) + (size div 4),
     lY - (size div 3) - (size div 4),
     lX + (size div 4) + (size div 2),
     lY + (size div 3) - (size div 4)
     );

     Canvas.Arc (
     lX,
     lY,
     lX - (size div 3),
     lY + (size div 2),
     lX - (size div 3) - (size div 4),
     lY + (size div 3) + (size div 4),
     lX - (size div 3) + (size div 4),
     lY + (size div 3) + (size div 4)

     );
end;


{$R *.lfm}


end.

