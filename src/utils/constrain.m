function x = constrain(x,a,b)
%CONSTRAIN Constrains a number to be within a range.
% Syntax
% 
% y = CONSTRAIN(x, a, b)
% 
% INPUT ARGUMENTS
% 
% x - number or array to constrain.
% a - the lower bound for y.
% b - the upper bound for y.
% 
% OUTPUT ARGUMENTS
% 
% y - constrained number or array
% returns x if ( a <= y <= b )
% returns a if ( x < a )
% returns b if ( x > b )
% 
% 2021-08-19 | Anatoli Ulmer | anatoli.ulmer@gmail.com

x(x<a)=a;
x(x>b)=b;

end

