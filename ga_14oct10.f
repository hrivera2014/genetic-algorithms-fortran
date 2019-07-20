c ************** algoritmo genetico *********************
c       implicit double precision (a-h,o-z)
        implicit none 
        integer ipoblacion,ilong_cromo,i,igen,ilong_gen,ib
        integer igeneracion,is,j,flag(40,2) 
        character*4 codigo(14)
        character*200 cromo(40),cromo_temporal,padres(2)
        character*200 swap
        character*50 expre_algebra,parser 
        real*8 fitnes(40),sum_fitnes,tot_fitnes,inc_fitnes
        real*8 xr,rebanada
        real*8 evaluar,comparacion
        real*8 dec,mut,crossover_rate
        real*8 target_number,fit_tot 
        integer*4 iran,indice(2)
        parameter (target_number=23.) 
c       ipoblacion debe ser un numero par        
        parameter (ipoblacion=40,ilong_cromo=200,ilong_gen=4)
        crossover_rate=0.7
        mut=0.001
c semilla aleatoria        
        iran=12572
c        iran=17572

        open(unit=36,file='fitnes.dat')
        open(unit=37,file='fitnes2.dat')

c               Codificacion de los digitos

        codigo(1) = '0000' !cero
        codigo(2) = '0001' !uno
        codigo(3) = '0010' !dos
        codigo(4) = '0011' !tres
        codigo(5) = '0100' !cuatro
        codigo(6) = '0101' !cinco
        codigo(7) = '0110' !seis
        codigo(8) = '0111' !siete 
        codigo(9) = '1000' !ocho
        codigo(10) = '1001' !nueve
        codigo(11) = '1010' ! +
        codigo(12) = '1011' ! -
        codigo(13) = '1100' ! *
        codigo(14) = '1101' ! /

c inicio de los cromosomas
        do i=1,ipoblacion
        cromo(i)=''
        indice(i)=0
        enddo 

c Se genera la poblacion aleatoria        
        do i=1,ipoblacion
                do j=1,50 ! 1 hasta la longitud del cromosoma/4
                call rnd001(xr,iran,14)
                igen=xr+1
                cromo(i)(j*4-3:j*4) = codigo(igen)
                enddo
        enddo

c *********   inicio del ciclo de evolucion  ************

 222    continue     
 
        do i=1,40
                cromo_temporal=cromo(i)
                expre_algebra=parser(cromo_temporal)
                comparacion=evaluar(expre_algebra)
                if (target_number.ne.comparacion) then
                fitnes(i)=1.d0/abs((target_number-comparacion))
                else
                fitnes(i)=1.d0
                endif
        enddo


c        do i=1,40
c        if (flag(i,2).eq.1) then
c        write(6,*) igeneracion,fitnes(i),evaluar(parser(cromo(i))),
c     + parser(cromo(i))
c        enddo
c        endif

        write(36,*)
     + igeneracion,(evaluar(parser(cromo(i))),i=1,40)
c        write(6,*)
c     + igeneracion,(cromo(i),(parser(cromo(i))),fitnes(i),i=1,1)

c Se escojen los padres a partir de la primera generacion       
c entre los individuos que mejor se adaptan        
c        Ruleta    
        
        indice(1)=0
        indice(2)=0

 555    call rnd001(xr,iran,40)
        is=xr+1
        call rnd001(xr,iran,1)
        if (xr.lt.fitnes(is).and.fitnes(is).ne.1.) then
        indice(1)=is
        padres(1)=cromo(indice(1))
        else
        goto 555
        endif

 777    call rnd001(xr,iran,40)
        is=xr+1
        call rnd001(xr,iran,1)
        if (xr.lt.fitnes(is).and.fitnes(is).ne.1.and.indice(1).ne.is)
     + then
        indice(2)=is
        padres(2)=cromo(indice(2))
        else
        goto 777
        endif 
        
c       Crossover        
        
        swap=''
        call rnd001(xr,iran,1)
        if(xr.lt.crossover_rate) then
                call rnd001(xr,iran,50)
                igen=xr+1
                swap=padres(1)(igen*4-3:200)
                padres(1)(igen*4-3:200)=padres(2)(igen*4-3:200)
                padres(2)(igen*4-3:200)=swap
        endif

c       Mutacion

        do ib=1,2
        do i=1,200
                call rnd001(xr,iran,1)
                if(xr.lt.mut) then
                     if(padres(ib)(i:i).eq.'1') then 
                         padres(ib)(i:i)='0'
                     else 
                         padres(ib)(i:i)='1' 
                     endif 
                endif 
        enddo
        enddo

c       Se sustituyen los padre por hijos        

        do i=1,2
        cromo(indice(i))=padres(i)
        enddo
        
        igeneracion=igeneracion+1

c Verifica si la mayoria de individuos de la poblacion han convergido        
        fit_tot=0
        do i=1,40
        cromo_temporal=cromo(i)
        expre_algebra=parser(cromo_temporal)
        comparacion=evaluar(expre_algebra)
        fit_tot=fit_tot+abs(comparacion)
        enddo
        write(37,*) igeneracion,fit_tot
        if(fit_tot.le.1000) goto 333 

        goto 222 



c 444    format(1x,i2,5(f9.3,1x))
c 22     format(1x,i6,1x,3(a200,1x))
c 20     format(1x,i6,1x,40(f9.3,1x))
c 33     format(1x,i6,1x,f9.3)

c---------------fin del programa  -------------
 333    continue
        stop
        end


c --------- funciones y subrutinas --------------------

c ------------- funcion decimal 2 ----------------
        
        function dec2(temp)
        implicit none 
        integer bin,k
        real decimal,dec2
        character*200 cromo_temporal
        character*4 temp
        
        decimal=0.
        
        do k=1,4
c        bin=ichar(cromo_temporal(201-k:201-k))
        bin=ichar(temp(5-k:5-k))
                
                if (bin.eq.49) then 
                        bin=1
                else 
                        bin=0
                endif 
        
        decimal=decimal+(real(bin)*(((2.**real(k-1)))))
c        write(*,*) 'stop'
        enddo
        dec2=decimal
        
        end

c ------ Funcion de calculo del parser que codifica el sujeto --------

        function parser(cromo_temporal)
        implicit none 
        character*200 cromo_temporal
        character*200 expresion
        character*50 expresion_algebra,parser
        character*1 algebra
        character*4 temp
        real dec,dec2,decimal,bufer
        integer i,icontador_deescojidos,k
c        write(*,*) 'cromo_temporal ',cromo_temporal
 
        expresion=''
        expresion_algebra=''
        bufer=999999
        i=0
        k=0
        icontador_deescojidos=0 

 100    continue
        
        i=i+1
        if (i.gt.50) goto 999 
        temp=cromo_temporal(i*4-3:i*4)
        decimal=dec2(temp)

        
c si / precede a 0  '/0'

        if(bufer.eq.13.and.decimal.eq.0.) then
        goto 100
        endif 

c       si no es operador o numero
        if(decimal.ge.14) then
        goto 100
        endif


        if(decimal.gt.9.and.icontador_deescojidos.eq.0) then
        goto 100
        endif

c busca hasta que encuentra el primer numero.

        if(icontador_deescojidos.eq.0.and.decimal.le.9) then
        bufer=decimal
        icontador_deescojidos=icontador_deescojidos+1
        k=icontador_deescojidos
        expresion(k*4-3:k*4)=temp
        expresion_algebra(k:k)=algebra(temp)
        goto 100
        endif
        

c       un operador antecedido de numero    5/

        if(decimal.gt.9.and.decimal.lt.14.and.bufer.le.9) 
     +   then
        bufer=decimal
        icontador_deescojidos=icontador_deescojidos+1
        k=icontador_deescojidos
        expresion(k*4-3:k*4)=temp   
        expresion_algebra(k:k)=algebra(temp)
        goto 100
        endif
        
c       un numero antecedido de operador    /4

         if(decimal.le.9.and.bufer.gt.9.and.bufer.lt.14) then
                bufer=decimal
                icontador_deescojidos=icontador_deescojidos+1
                k=icontador_deescojidos
                expresion(k*4-3:k*4)=temp
                expresion_algebra(k:k)=algebra(temp)
         goto 100
         endif

c       un numero antecedido de numero        
        if(decimal.le.9.and.bufer.le.9) then
        goto 100
        endif

c       un operador antecedido de operador       
        if(decimal.gt.9.and.bufer.lt.14.and.bufer.gt.9) then
        goto 100
        endif
                
        if(i.eq.50.and.decimal.gt.9) goto 999        
         

 999    continue  
        
        if(bufer.gt.9) then
        expresion_algebra(k:k)=''
        endif
        parser=expresion_algebra
        end
        
c------------ funcion que evalua la expresion algebraica  --------

        function evaluar(expre_algebra)
        implicit none
        character*50 expre_algebra
        real evaluar,evaluar2
        character*1 parser_temporal,c
        integer i,k,selector,bufer(50)

        do i=1,50
        selector=ichar(expre_algebra(i:i))     
        select case (selector)
        case (48)
        bufer(i)=0
        case (49)
        bufer(i)=1
        case (50)
        bufer(i)=2
        case (51)
        bufer(i)=3
        case (52)
        bufer(i)=4
        case (53)
        bufer(i)=5
        case (54)
        bufer(i)=6
        case (55)
        bufer(i)=7
        case (56)
        bufer(i)=8
        case (57)
        bufer(i)=9
        case (43)
        bufer(i)=10
        case (45)
        bufer(i)=11
        case (42)
        bufer(i)=12
        case (47)
        bufer(i)=13
        case default
        bufer(i)=0
        end select
        enddo

        evaluar2=bufer(1) 
        do i=2,49,2   
        select case (bufer(i))
        case(10)
         evaluar2=evaluar2+bufer(i+1)
        case(11)
         evaluar2=evaluar2-bufer(i+1)
        case(12)
         evaluar2=evaluar2*bufer(i+1)
        case(13)
         evaluar2=evaluar2/bufer(i+1)
        case default
        evaluar2=evaluar2
        end select
        enddo 
        evaluar=evaluar2
        
        end

c **************** funciones llamadas por funciones **********

        function algebra(temp)
        implicit none
        character*4 temp
        character*1 algebra
        real decimal,dec2
        integer selector
        
        decimal=dec2(temp)
        selector=decimal
        
        select case (selector)
        case (0)
        algebra='0'
        case (1)
        algebra='1'
        case (2)
        algebra='2'
        case (3)
        algebra='3'
        case (4)
        algebra='4'
        case (5)
        algebra='5'
        case (6)
        algebra='6'
        case (7)
        algebra='7'
        case (8)
        algebra='8'
        case (9)
        algebra='9'
        case (10)
        algebra='+'
        case (11)
        algebra='-'
        case (12)
        algebra='*'
        case (13)
        algebra='/'
        case default
        stop
        end select
        end
 
c Función random

        subroutine rnd001(xi,i,ifin)
        integer*4 i,ifin
        real*8 xi
        i=i*54891
        xi=i*2.328306e-10+0.5D00
        xi=xi*ifin
        return
        end
