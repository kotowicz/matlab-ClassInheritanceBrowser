classdef Tree < handle
    % Tree implementation
        
    % Copyright 2012 Clayton Ernst, Andrew Hagen, Eric Lee and Andreas Kotowicz
    % Written for Engineering 177 Spring 2010, Final Project. Professor:
    % Andy Packard, UC Berkeley.
    
    properties (SetAccess = private)
        myChildren
    end
    
    properties
        myInfo
    end
    
    methods
        function T = Tree(info, children)
            if (nargin == 1)
                T.myChildren = {};
            else
                T.myChildren = children;
            end
            T.myInfo = info;
        end

        function set.myChildren(T,newChildren)
            if isa(newChildren,'cell')
                for i = 1:length(newChildren)
                    if not(isa(newChildren{i},'classInheritance.Tree'))
                        error('myChildren must be a cell array of trees')
                    end
                end
                T.myChildren = newChildren;
            else
                error('myChildren must be a cell array of trees')
            end
        end        
                
        function addChild(T,newTree)
            if isa(newTree,'classInheritance.Tree')
                T.myChildren = horzcat(T.myChildren, {newTree});
            elseif isa(newTree,'cell')
                T.myChildren = horzcat(T.myChildren, newTree);
            end
        end        
        
        function numNodes = countNodes(T)
            numNodes = 0;
            if isempty(T.myChildren)
                numNodes = 1;
            else
                for i = 1:length(T.myChildren)
                    numNodes = numNodes + countNodes(T.myChildren{i});
                end
                numNodes = numNodes + 1;
            end
        end
        
        function treeDepth = depth(T)
            depthArray = zeros(1,length(T.myChildren));
            if isempty(T.myChildren)
                treeDepth = 1;
            else
                for i = 1:length(T.myChildren)
                    depthArray(i) = 1 + depth(T.myChildren{i});
                end
                treeDepth = max(depthArray);
            end
        end        
        
        function nodeList = breadthTrav(T)
            nodeList{1} = T;
            k = 1;
            kBefore = k;
            tempT = {T};
            for treeLevel = 2:depth(T)
                for currentTree = 1:length(tempT)
                    if not(isempty(tempT{currentTree}.myChildren))
                        for i = 1:length(tempT{currentTree}.myChildren)
                            nextTree = tempT{currentTree}.myChildren{i};
                            if not(cellfun(@(t) (t.equals(nextTree)), nodeList))
                                nodeList{k+i} = tempT{currentTree}.myChildren{i};
                            else
                                k = k - 1;
                            end
                        end
                        k = k + length(tempT{currentTree}.myChildren);
                    end
                end
                tempT = {nodeList{ kBefore+1 : k }};
                kBefore = k;
            end
        end
       
        function bool = equals(T,otherT)
            bool = (strcmp(T.myInfo,otherT.myInfo));
        end
        
        function CNID = getCNID(T)
            % CNID is a cell array. CNID{1} is the Connection Matrix and
            % CNID{2} is the ID array.
            nodeList = T.breadthTrav;
            numNodes = length(nodeList);
            if (numNodes == 1)
                CN = 1;
                IDs = nodeList{1}.myInfo;
            else
                CN = zeros(numNodes);
                IDs = cell(1,numNodes);
                s = struct;
                for i = 1:numNodes
                    nodeName = nodeList{i}.myInfo;
                    s.(nodeName) = i;
                end
                for i = 1:numNodes
                    currentNode = nodeList{i};
                    IDs{i} = currentNode.myInfo;
                    for x = 1:length(currentNode.myChildren)
                        currentChild = currentNode.myChildren{x};
                        CN(i,s.(currentChild.myInfo)) = 1;
                    end
                end
            end
            CNID = {CN IDs};
        end        
    end    
end

% Class Inheritance Browser Copyright Clayton Ernst, Andrew Hagen, Eric Lee and Andreas Kotowicz 2012. 
