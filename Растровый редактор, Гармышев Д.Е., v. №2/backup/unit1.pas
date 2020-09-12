unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ActnList,
  Menus, ColorBox, ComCtrls, StdCtrls;

type

  { TFormGarmDraw }

  TFormGarmDraw = class(TForm)
    CBtnGarmColorBrush: TColorButton;
    BtnGarmChangeDrawErase: TButton;
    CBtnGarmColorBackground: TColorButton;
    BtnApplyBackgroundColor: TButton;
    BtnGarmClearBackground: TButton;
    GarmMainMenu: TMainMenu;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MainMenu1: TMainMenu;
    MIGarmSelectedOption: TMenuItem;
    MIGarmPointsDraw: TMenuItem;
    MIGarmLinesDraw: TMenuItem;
    MenuItem3: TMenuItem;
    MIGarmSimpleDraw: TMenuItem;
    MIGarmSimpleErase: TMenuItem;
    Panel1: TPanel;
    SBGarmBrushSize: TScrollBar;
    procedure BtnGarmChangeDrawEraseClick(Sender: TObject);
    procedure BtnApplyBackgroundColorClick(Sender: TObject);
    procedure BtnGarmClearBackgroundClick(Sender: TObject);
    procedure GarmMouseEnter(Sender: TObject);
    procedure GarmMouseLeave(Sender: TObject);
    procedure GarmFormCreate(Sender: TObject);
    procedure GarmMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GarmMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure GarmMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MIGarmPointsDrawClick(Sender: TObject);
    procedure MIGarmLinesDrawClick(Sender: TObject);
    procedure MIGarmSimpleDrawClick(Sender: TObject);
    procedure MIGarmSimpleEraseClick(Sender: TObject);
    procedure SBGarmBrushSizeChange(Sender: TObject);
  private

  public

  end;

var
  FormGarmDraw: TFormGarmDraw;

implementation
var
  //Переменные необходимые для регулирования режимов рисования
 bDrawOn, bEraseOn, bDrLine: boolean;
 r, t: integer; //Радиус и толщина кисти
 drawType: integer; //В главном меню выбираем что именно мы хотим нарисовать
 //Начальные и конечные точки рисования (x1 и y1 нужны для рисования линиями)
 X0,Y0: integer;
 X1,Y1: integer;



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
 Randomize;
end;

//Процедура срабатывает когда мышка уходит за пределы области рисования
procedure TFormGarmDraw.GarmMouseLeave(Sender: TObject);
begin
 if bEraseOn then
 begin
      Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r);
 end;

end;

//Процедура срабатывает когда мышка входит в пределы области рисования
procedure TFormGarmDraw.GarmMouseEnter(Sender: TObject);
begin
   if bEraseOn then
   begin
      Canvas.Ellipse(x0-r,y0-r,x0+r,y0+r);
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

//Кнопка нужна для применения нового цвета фона
procedure TFormGarmDraw.BtnApplyBackgroundColorClick(Sender: TObject);
begin
  FormGarmDraw.Color := CBtnGarmColorBackground.ButtonColor;
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
       end;

end;

{
Процедура срабатывает при движении мыщи по области рисования
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

            2:
              begin
               if(bDrawOn) then
               begin
               Canvas.Pen.Width := SBGarmBrushSize.Position;
               Canvas.MoveTo(X0,Y0);
               Canvas.LineTo(X1,Y1);
               X1:=X; Y1:=Y;
               Canvas.MoveTo(X0, Y0);
               Canvas.LineTo(X,Y);
               end;
            end;

            3: begin

                {
                Если мы не стираем и не рисуем, сохраняем последнюю позицию мыши на холсте
                В некоторых случаях это помогает избежать ситуации когда при начале рисования рисуется линия
                из другого конца холста
                }
                if (not bDrawOn and bdrLine) or (not bDrawOn and bEraseOn) then
                Canvas.moveTo(x, y);

                //Срабатывает когда мы просто рисуем
                if bDrawOn and bdrLine then
                begin
                     Canvas.Pen.Width:=SBGarmBrushSize.position; //Ширина линий при рисовании.
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
            end;
     end;
end;

//Процедура срабатывает при отпускании клавиши мыши
procedure TFormGarmDraw.GarmMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     bDrawOn := false; //Сразу говорим всей программе что была отпущена клавиша

     case drawType of
            1: begin
               end;

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

     BtnGarmChangeDrawErase.enabled := false;

     MIGarmSelectedOption.Caption := 'Рисование линиями';
end;

//Режим рисования
procedure TFormGarmDraw.MIGarmSimpleDrawClick(Sender: TObject);
begin
     drawType := 3;
     BEraseOn:=False;
     bDrLine := True;

     Canvas.Pen.Width:=3;
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


//Срабатывает когда мы двигаем ползунок изменения ширины кисти/ластика
procedure TFormGarmDraw.SBGarmBrushSizeChange(Sender: TObject);
begin
     r := SBGarmBrushSize.position;
end;





{$R *.lfm}


end.

