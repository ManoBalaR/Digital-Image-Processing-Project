function [ o_str ] = ocr( img )
    %Werkt enkel voor duitse nummerplaten want alleen daarvan vond ik een
    %alfabet
    wait=1;
	%img is de reeds gesegmenteerde nummerplaat
    [h,w,f]=size(img);
    imshow(img);
    pause(wait);
    [h,w,f]=size(img);
    img = rgb2gray(img);
    imshow(img);
    pause(wait);
	%ook deze afbeelding zetten we om naar een binaire afbeelding
    img=~(img<100);
    imshow(img);
    pause(wait);
	%adhv deze functie worden alle zwarte delen in de afbeelding die geconnecteerd zijn volgens 8-connectiviteit en die kleiner zijn dan een aantal pixels (afhankelijk van de afmetingen) verwijderd.
    img=~bwareaopen(~img, round((h*w)*0.02));
    imshow(img);
    pause(wait);
	%hier worden alle geconnecteerde gelabeld 
    [L Ne]=bwlabel(not(img));
    gem=zeros(1);
    for n=1:Ne
	  %hier gaan we op zoek naar het aantal pixels per geconnecteerde regio, zodat we vervolgens het gemiddelde hiervan als treshold kunnen gebruiken
      [r,c] = find(L==n);
      n1=img(min(r):max(r),min(c):max(c));
      gem(n)=bwarea(n1)
    end
    gem=mean(gem);
    tresh=2;
    width=0;
    height=0;
    verhoudingtresh=1.1;
    perc=0;
    letters={'a','b','c','d','e','f','g','h','i','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9'};
    str='';
	%nu gaan we elke geconnecteerde regio aflopen en zien of ze voldoen aan de specificaties van een letter
    for n=1:Ne
      [r,c] = find(L==n);
      n1=img(min(r):max(r),min(c):max(c));
      height=max(r)-min(r)+1;
      width=max(c)-min(c)+1;
      perc=bwarea(n1)/(height*width);
	  %als de regio voldoet aan volgende specificaties zal het behandelt worden als een letter anders wordt het verwijderd
	  %1. de oppervlakte van de regio groter is dan de helft van de gemiddelde oppervlakte van de regio's en kleiner dan het dubbel.
	  %2. als de hoogte groter is dan de (breedte+10%van de breedte)
	  %3. Als de regio meer dan 30% van de totale oppervlakte van de gelabelde segmentatie bevat
      if(~(bwarea(n1)<gem(1)/tresh || bwarea(n1)>gem(1)*tresh)) && height>(width*verhoudingtresh) && perc>0.3
          imshow(n1);
          perc2=0;
          bestmatch=1;
		  %zodra de regio voldoet aan bovenstaande specificaties, vergelijken we de regio met afbeeldingen van letters in de database
          for(t=1:35)
            imfile=strcat('images/ocr/',char(letters(t)),'.jpg');
            LL=imread(imfile);
			%we maken de database-afbeelding even groot als de regio
            LL=imresize(LL,[height width]);
            LL = rgb2gray(LL);
            level = graythresh(LL);
			%we zetten de database afbeelding om naar een binaire afbeelding
            LL = im2bw(LL,level);
			%we vergelijken de database afbeelding met de regio adhv een logische AND
            LL=n1 & LL;
            
            percv=bwarea(LL)/(height*width);
			%de regio die procentueel het meest aantal zwarte pixels gelijk heeft met de database afbeelding zal beschouwd worden
			%als de letter die we zoeken. Die letter tellen we op bij de string die de nummerplaat moet voorstellen
            if(percv>perc2)
                perc2=percv;
                bestmatch=t;
            end
          end
          str=strcat(char(str),char(letters(bestmatch)));
      else
          img(min(r):max(r),min(c):max(c))=1;
      end
      pause(wait);
    end
    o_str=str
    imshow(img);
    
    
    
end

