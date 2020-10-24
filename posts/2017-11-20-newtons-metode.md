{"title": "Finn kvadratrot med Newton's metode"}

![]({{ blog.siteurl }}/blogimages/isac-newton.jpg)

Hvordan beregne kvadratrota av tall? For eksempel er `7`
kvadratrota til `49`. Det fins ingen åpenbar måte å regne seg
fram til et eksakt svar.

Men vi kan komme veldig nært ved å gjette oss framover.

Hvis vi skal finne kvadratrota til `49` kan vi f.eks. starte
med `1` og beregne `1 * 1` og se hvor nærme vi treffer.

Etter hver gjetning forbedrer vi gjetningen med å plusse på
f.eks. `0.1` og beregne `1.1 * 1.1 = 1.21` osv osv
helt til differansen mellom `49` og `guess * guess` er
f.eks mindre enn `0.0001`.

Den mest kjent måten å forbedre gjetningen er å anvende
[Newton's metode](https://en.wikipedia.org/wiki/Newton%27s_method)
 som tar snittet av `guess` og `x/guess`.

Implementert i Common Lisp:

    (defun sqrt (x)
      (sqrt-iterative 1.0 x))
    
    (defun sqrt-iterative (guess x)
      (if (good-enough? guess x)
        guess
        (sqrt-iterative (improve guess x) x)))
    
    (defun improve (guess x)
      "Improve guess with Newton's method"
      (/ (+ guess (/ x guess)) 2))
    
    (defun good-enough? (guess x)
      (< (abs (- x (* guess guess)))
         0.0001))
    
    (print (sqrt 2)) ; Printer 1.4142157

De gradvise gjetningene er:

    1.0
    1.5
    1.4166667
    1.4142157
    1.4142157

Legg merke til at funksjonen `sqrt-iterative` er iterativ (looper)
uten bruk av språk looper som `for`, `while`, `do` osv. Selve 
funksjonen er **rekursivt definert** men prosessen er **iterativ**.

Looping er implementert med funksjonskall.

Er du bekymret for ytelsen i å bruke funksjonskall som
iterasjon kan du lese om
[tail recursion](https://en.wikipedia.org/wiki/Tail_call);
en teknikk som unngår ny stack frame for hvert kall.
