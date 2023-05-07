function cycle_index(i, max_i) = (
    i < 0     ? cycle_index(max_i + 1 - abs(i), max_i) :
    i > max_i ? cycle_index(i - (max_i + 1), max_i) :
    i
);

assert(cycle_index(-1, 3) == 3);
assert(cycle_index(4, 3) == 0);


function reverse_vector(v) = (
    let(max_i = len(v) - 1)
    [ for (i = [ 0 : max_i]) v[max_i - i] ]
);
    
assert(reverse_vector([1, 2, 3, 4]) == [4, 3, 2, 1]);
    

function reverse_deltas(v) = (
    // [ for (delta = reverse_vector(v)) [-1 * delta.x, -1 * delta.y, delta[2]] ]
    
    let(max_i = len(v) - 1)
    
    [ 
        for (i = [ 0 : max_i]) 
            [
                -1 * v[max_i - i].x, 
                -1 * v[max_i - i].y, 
                v[cycle_index(max_i - i - 1, max_i)][2]
            ]
    ]
);


function mirror_delta(delta, direction) = (
    direction == "right" || direction == "left" ? [-1 * delta.x,      delta.y, delta[2]] :
    direction == "up"    || direction == "down" ? [     delta.x, -1 * delta.y, delta[2]] :
    undef
);

assert(mirror_delta([-2, 2, 1], "right") == [ 2,  2, 1], "mirror_delta() failed test 1");
assert(mirror_delta([-2, 2, 1], "down")  == [-2, -2, 1], "mirror_delta() failed test 2");


function mirror_deltas(deltas, direction) = (
    [ for (i = [ 0 : len(deltas)-1]) mirror_delta(deltas[i], direction) ]
);
        
assert(mirror_deltas([[-1, -0.5, 0], [1, -0.5, 0]], "right") == [[1, -0.5, 0], [-1, -0.5, 0]]);


function mirrorextend_deltas(deltas, direction) = (
    let(mirrored_deltas = mirror_deltas(deltas, direction))
        
    concat(
        deltas, 
        reverse_deltas(
            [ for (i = [ 1 : len(deltas)-1]) mirrored_deltas[i] ]
        )
    )
);
  
  
echo(mirrorextend_deltas([[-1, -0.5, 1], [1, -0.3, 0]], "right"));
//            :[[-1, -0.5, 1], [1, -0.3, 0], [1, 0.3, 0]]
            
//assert(
//    mirrorextend_deltas([[-1, -0.5, 1], [1, -0.3, 0]], "right") == [[-1, -0.5, 1], [1, -0.3, 0], [1, 0.3, 1]],
//    "mirrorextend_deltas() failed test 1"
//);
            
            
function translate_path(v, path) = (
    // @todo Implementation. This is simple, as only the starting point has to be translated.
    undef
);
