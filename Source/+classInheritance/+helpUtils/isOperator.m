function [b, topic] = isOperator(topic, asFunctions)
    b = length(topic)<=3 && all(isstrprop(topic, 'alphanum')) == 0;
    if b
        whichTopic = which(topic);
        if ~isempty(whichTopic)
            newTopic = regexp(whichTopic, '\w+(?=\.[mp]$|\)$|$)', 'match', 'once');
            fullTopic = which([newTopic '.m']);
            if ~isempty(fullTopic)
                if nargin>1 && asFunctions
                    topic = newTopic;
                    b = false;
                else
                    topic = fullTopic;
                end
            end
        end
    end
end
