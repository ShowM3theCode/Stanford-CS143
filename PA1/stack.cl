(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)

class List {
   -- Define operations on empty lists.

   isNil() : Bool { true };

   -- Since abort() has return type Object and head() has return type
   -- Int, we need to have an Int as the result of the method body,
   -- even though abort() never returns.

   head()  : String { { abort(); ""; } };

   -- As for head(), the self is just to make sure the return type of
   -- tail() is correct.

   tail()  : List { { abort(); self; } };

   -- When we cons an element onto the empty list we get a non-empty
   -- list. The (new Cons) expression creates a new list cell of class
   -- Cons, which is initialized by a dispatch to init().
   -- The result of init() is an element of class Cons, but it
   -- conforms to the return type List, because Cons is a subclass of
   -- List.

   cons(i : String) : List {
      (new Stack).init(i, self)
   };

};

class Stack inherits List {

   car : String;	-- The element in this list cell

   cdr : List;	-- The rest of the list

   isNil() : Bool { false };

   head()  : String { car };

   tail()  : List { cdr };

   init(i : String, rest : List) : List {
      {
	 car <- i;
	 cdr <- rest;
	 self;
      }
   };

};

class StackCommand inherits IO {
    myStack : List;
    str : String;
    z : A2I;
    x1 : Int;
    x2 : Int;
    s1 : String;
    s2 : String;
    
   print_list(l : List) : Object {
      if ((l.head() = "")) then { 1; }
                   else {
			   out_string(l.head());
			   out_string("\n");
			   print_list(l.tail());
		        }
      fi
   };
    
    work(l : List) : Object {
      {
        myStack <- l;
        z <- new A2I;
        out_string(">");
        while (not ((str <- in_string()) = "x")) loop {
            out_string(str);
            out_string("\n");
            if (str = "d") then {
                print_list(myStack);
            }
            else if (str = "e") then {
                str <- myStack.head();
                if (str = "+") then {
                    myStack <- myStack.tail();
                    x1 <- z.a2i(myStack.head());
                    myStack <- myStack.tail();
                    x2 <- z.a2i(myStack.head()); 
                    x1 <- x1 + x2;
                    myStack <- myStack.tail().cons(z.i2a(x1));
                }
                else if (str = "s") then {
                    myStack <- myStack.tail();
                    s1 <- myStack.head();
                    myStack <- myStack.tail();
                    s2 <- myStack.head(); 
                    myStack <- myStack.tail().cons(s1).cons(s2);
                }
                else { 1; }
                fi fi;
            }
            else {
                myStack <- myStack.cons(str);
            }
            fi fi;
            out_string(">");
        }
        pool;
        out_string(str);
        out_string("\n");
      }
    };
};

class Main inherits IO {
    myStack : List;
    sc : StackCommand;
    
    main() : Object {
      {
        myStack <- new List.cons("");
        sc <- new StackCommand;
        sc.work(myStack);
      }
    };

};
