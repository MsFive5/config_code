function class_id = find_class(x,label_state)
    
    ind1 = find(label_state(1,:)<=x,1,'last');
    ind2 = find(label_state(2,:)>=x,1,'first');
    
    if(ind1==ind2)
        class_id = label_state(3,ind1);
    else
        class_id = 0;
    end