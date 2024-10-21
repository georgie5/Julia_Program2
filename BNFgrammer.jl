
currderiv = nothing
line_count = 0


#function to display grammer
function display_BNF_grammar()
    grammar = """
    =============================================================================
    <program>     ->  wake <assignments> sleep
    <assignments> ->  <assignments> -> <key-assign> | <key-assign> <assignments>
    <key-assign>  ->  key <key> = <movement> ;
    <key>         ->  a | b | c | d
    <movement>    ->  DRIVE | BACK | LEFT | RIGHT | SPINL | SPINR
    =============================================================================
    """
    println(grammar)
end

#function to check if it starts with wake and sleep
function procDeriv(userInput)
  
    # Trim leading and trailing whitespace
    userInput = strip(userInput)

    # Check if the input contains "wake" and "sleep"
    wake_count = occursin("wake", userInput)
    sleep_count = occursin("sleep", userInput)

    if wake_count > 1 || sleep_count > 1
        println("Error: The input string should have exactly one 'wake' and one 'sleep'.")
        return false
    end

    # Check if the input starts with "wake" and ends with "sleep"
    if !startswith(userInput, "wake") && !endswith(userInput, "sleep")
        println("Error: The input string should start with 'wake' and end with 'sleep'.")
        return false
    elseif !startswith(userInput, "wake")
        println("Error: The input string should start with 'wake'.")
        return false
    elseif !endswith(userInput, "sleep")
        println("Error: The input string should end with 'sleep'.")
        return false
    end

    # Update current derivation and line count
    global currderiv = "<program> -> wake <assignments> sleep"
    global line_count += 1
    println(line_count," ",currderiv)
   

    # Remove "wake" and "sleep" from the input for further processing
    userInput = replace(userInput, "wake"=>"")
    userInput = replace(userInput, "sleep"=>"")
    userInput = strip(userInput)

    # Pass the processed input to the assignments derivation function
    if !procAssignments(userInput)
        return false  # If procAssignments fails, terminate the derivation
    end
    return true
end

#function to process <assignment> to check if it has 1 key assing or more.
function procAssignments(userInput)

    userInput = strip(userInput)

    # Error check: should not have consecutive semicolons (';;')
    if occursin(";;", userInput)
        println("Error: Input contains consecutive semicolons (';;').")
        return false
    end

    # Error check: should contain at least one semicolon
    if count(i->(i==';'),userInput)==0
        println("Error: No semicolons (';') found. Key assignments should end with a semicolon.")
        return false
    end

    #count the amount of ';' in the userInput string. 
    if count(i->(i=='='),userInput)==1
        # Single key assignment, replace <assignments> with <key-assign>
        global currderiv = replace(currderiv, "<program>"=>"         ",count=1)
        global currderiv = replace(currderiv, "<assignments>"=>"<key-assign>",count=1)
        global line_count += 1
        println(line_count," ",currderiv)

         # Call the keyAssignDeriv function to handle this single key assignment
         if !keyAssignDeriv(userInput)
            return false  # If keyAssignDeriv fails, terminate the derivation
         end

    elseif count(i->(i=='='),userInput)>=1 
        # Multiple key assignments, replace <assignments> with <key-assign><assignments>
        global currderiv = replace(currderiv, "<program>"=>"         ",count=1)
        global currderiv = replace(currderiv, "<assignments>"=>"<key-assign><assignments>",count=1)
        global line_count += 1
        println(line_count," ",currderiv)

        # Split the input into leftpart and rightpart on the first semicolon
        parts = split(userInput, ";", limit=2)
        leftpart = strip(parts[1])
        rightpart = strip(parts[2])

        
        # Call the keyAssignDeriv function to handle the left part
        if !keyAssignDeriv(leftpart)
            return false  # If keyAssignDeriv fails, terminate the derivation
        end

        # Recursively call procAssignments on the right part if not empty
        if !isempty(rightpart)
            return procAssignments(rightpart)
        end
    end
    return true
end

#function to validate both <key> and <movement> 
function keyAssignDeriv(userInput)

    userInput = replace(userInput, ";"=>"")
    userInput = strip(userInput)

    global currderiv
    global line_count

     # Derivation steps for key-assign
     currderiv = replace(currderiv, "<key-assign>"=>"key <key> = <movement>;",count=1)
     line_count += 1
     println(line_count," ",currderiv)

    # Split the key assignment into key and movement
    parts = split(userInput, "=")
    if length(parts) != 2
        println("Invalid key-assignment format make sure key-assign ends with ';' ")
        return false
    end

    key = strip(parts[1])
    movement = strip(parts[2])

    # Validate key
    if !(key in ["a", "b", "c", "d"])
        println("Invalid key: '$key'. Expected 'a', 'b', 'c', or 'd'.")
        return false
    end

   # Replace <key> with the actual key
    currderiv = replace(currderiv, "<key>"=>key,count=1)
    line_count += 1
    println(line_count," ",currderiv)

    # Validate movement
    if !(movement in ["DRIVE", "BACK", "LEFT", "RIGHT", "SPINL", "SPINR"])
        println("Invalid movement: '$movement'. Expected a valid movement like DRIVE, BACK, LEFT, etc.")
        return false
    end

    # Replace <movement> with the actual movement
    currderiv = replace(currderiv, "<movement>"=>movement,count=1)
    line_count += 1
    println(line_count," ",currderiv)

    return true
end

# Main program
function main()
   
    # Display the grammer
    display_BNF_grammar(); 
    
    while true
       
        global line_count = 0
        global currderiv = nothing

        println("\nEnter an input string or 'ABORT' to terminate: \n")
        userInput = readline()
        println("\n")
        if userInput == "ABORT"
            println("Program terminated...")
            break
        end
           
        procDeriv(userInput)  # Attempt to process the derivation
    
    end
end

main()
