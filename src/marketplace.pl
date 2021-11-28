% TODO : Check if in market, Equipments level, Sync inventory

% DEBUG CODE STARTS HERE
% :- dynamic(gold/1).
% :- include('inventory.pl').
% :- include('items.pl').
% :- dynamic(inMarket/1).
% :- dynamic(totalGold/1).
% inMarket(t).

% totalGold(5000).
% gold(5000).
% DEBUG CODE ENDS HERE

market :-
    inMarket(_),
    write('Welcome to the secret shop!'),nl,
    write('1. Beli'),nl,
    write('2. Jual'),nl,
    write('3. Upgrade Equipment'), nl,
    write('4. Mo pulang ajh'), nl,
    write('Masukkan pilihan: '),read(X),
    (X =:= 1 -> beli;
    X =:= 2 -> jual;
    X =:= 3 -> upgradeEq;
    X =:= 4 -> exitMarket),nl,
    !.

market :-
    \+inMarket(_),
    write('Kamu tidak berada pada market.'),nl,
    !.


beli :-
    write('Mau beli apa?'),nl,
    write('1. Seed'),nl,
    write('2. Ranch animal'),nl,
    write('3. Animal food'),nl,
    
    write('Masukkan pilihan: '), read(X),
    (X =:= 1 -> buySeed;
    X =:= 2 -> buyAnimal;
    X =:= 3 -> buyAnimalFood;
    X =:= 4 -> exitMarket;
    write('Invalid input.'), nl, nl, market),nl,nl,
    !.

printMarket([]).
printMarket([A|B]) :-
    itemName(A, Nama),
    priceItem(A, Harga),
    write('- '), write(Nama), write(' ('), write(Harga), write(' G)'), write(', Kode: '), write(A),nl,
    printMarket(B).

buySeed :-
    write('Seed market. The finest there is.'), nl,
    findall(Nama, item(seed, Nama), ListNama),
    printMarket(ListNama), nl,
    write('Pilihanmu (kode): '),
    read(Input), nl,
    (item(seed,Input) -> buyItem(Input);
    \+item(seed,Input) -> !, write('Tidak ada item itu hei! Balik sana ke market!'), nl, nl, market),
    !.


buyAnimal :-
    write('TOKO HEWAN FFfFFfAy o((>ω< ))o.'), nl,
    findall(Nama, item(animal, Nama), ListNama),
    printMarket(ListNama), nl,
    write('Pilihanmu (kode): '),
    read(Input), nl,
    (item(animal,Input) -> buyItem(Input), initAnimal(Input);
    \+item(animal,Input) -> !, write('Tidak ada item itu hei! Balik sana ke market!'), nl, nl, market),
    !.

buyAnimalFood :-
    write('Animal food market. Your cow will love it.'), nl,
    findall(Nama, item(feed, Nama), ListNama),
    printMarket(ListNama), nl,
    write('Pilihanmu (kode): '),
    read(Input), nl,
    (item(feed,Input) -> buyItem(Input);
    \+item(feed,Input) -> !, write('Tidak ada item itu hei! Balik sana ke market!'), nl, nl, market),
    !.

buyItem(Item) :-
    gold(G),
    priceItem(Item, Price),
    G >= Price,
    GNew is G - Price,
    addItem(Item),
    retract(gold(G)),
    asserta(gold(GNew)),
    itemName(Item, Name),
    write('Berhasil membeli satu '), write(Name), write('!'), nl,
    write('Mau beli apa lagi?'), nl, nl,
    market,
    !.

buyItem(Item) :-
    gold(G),
    priceItem(Item, Price),
    G < Price,
    write('Duit kamu kurang :( Sana kerja lagi!'), nl,
    market,
    !.

exitMarket :-
    write('Buh-bye!'), nl,
    !.

jual :-
    currInventory(Inventory),
    showRemoveableInventory, nl,
    write('Pilihanmu (COMMAND): '), read(Input),nl,
    (\+member(Input, Inventory) -> itemName(Input, ItemName), format('There is no ~w in your inventory!\n', [ItemName]), market;
    member(Input, Inventory) -> write('Mau jual berapa? '), read(Amount), nl, jualItem(Input, Amount)),
    !.

jualItem(_, Amount) :-
    Amount < 1,
    write('Invalid amount. Mengembalikan ke menu jual...'),
    jual,
    !.

jualItem(Input, Amount) :-
    gold(G),
    totalGold(TG),
    throwItem(Input,Amount),
    priceItem(Input,Price),
    itemName(Input, ItemName),
    TotalPrice is Amount * Price,
    GNew is G + TotalPrice,
    TGNew is TG + TotalPrice,
    retract(gold(G)),
    asserta(gold(GNew)),
    retract(totalGold(TG)),
    asserta(totalGold(TGNew)),
    format('Berhasil menjual ~w sebanyak ~w buah!', [ItemName,Amount]), nl,
    format('Anda mendapatkan ~w gold.', [TotalPrice]),nl,
    write('Mengembalikan ke menu market..'), nl, nl,
    market,
    !.


% upgradeEq :-
