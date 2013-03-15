classdef iTree < handle
    % Creates and displays class inheritance Tree structures for classes in 
    % a given directory or package
    
    % directory is the path to the desired directory, relative to the
    % current directory (containing the classInheritance package)
    
    % metalist is a cell array of structures representing all
    % classes in the directory and all inherited superclasses.
    % Fields are: Name, Properties.Name, Methods.Name,
    % Methods.DefiningClass, SuperClasses.Name, and InferiorClasses.Name
    
    % treelist is the cell array of Tree objects, where each myInfo field
    % corresponds to the name of a class in metalist, and the myChildren
    % fields are assigned according to inheritance
    
    % Note: In both metalist and treelist, display names of classes 
    % contained in packages are modified from the packagename.classname
    % syntax to packagename_classname
    
    % rootIdx is an index to the roots of the inheritance trees.
    % roots are those classes who have no superclasses.
    % (indices correspond to both metalist and treelist)
    
    % h is the handle to the biograph object, initiated upon calling 'view'
    
    % Copyright 2012 Clayton Ernst, Andrew Hagen, Eric Lee and Andreas Kotowicz
    % Written for Engineering 177 Spring 2010, Final Project. Professor:
    % Andy Packard, UC Berkeley.
    
    properties (SetAccess = private)
        directory
        fullpath % fullpath to the class / directory.
        metalist = {}
        treelist
        rootIdx = [];
        h
    end
    
    properties (Access = private)
        fighan
    end        
    
    %% PUBLIC methods
    methods
        function obj = iTree(varargin)
            
            if nargin == 0
                obj.directory = '.';
            elseif nargin == 1
                obj.directory = varargin{:};
            else
                error('classInheritance:iTreeWrongNumerInputs', 'Error: Only zero or one arguments allowed.');
            end

            [wh, pre, dir0] = find_class_directory(obj);
            find_classes_in_dir(obj, wh, pre, dir0);
            fill_metalist(obj, dir0);
            
        end
        
        %% FIND directory for user supplied class
        function [wh, pre, dir0] = find_class_directory(obj)
            % get directory (or package) info
            wh = what(obj.directory);
            nbr_dirs = numel(wh);
            
            if nbr_dirs == 0
                
                % try harder to find object that user wants to see
                this_plugin = which(obj.directory);
                if isempty(this_plugin)  % let's give up
                    error('classInheritance:iTreeClassNOTFOUND', 'Error: Class not found. Please check if class name is correct or try again using full path to class.');
                end
                % we found a winner, extract the directory name
                dir_to_open = fileparts(this_plugin);
                obj.directory = dir_to_open;
                wh = what(dir_to_open);
                
            elseif nbr_dirs > 1
                disp('More than one directory found, will use first one.');
                wh = wh(1);
            end

            % add the current directory to the matlab path
            dir0 = pwd;
            % make sure we don't try to add a classpath (like @myclass)
            pathstr = fileparts(dir0);
            addpath(pathstr);

            % check for nested packages; assign prefix if necessary
            pre = ''; moddir = obj.directory;
            if ~isempty(strfind(obj.directory,'+'))
                pkgIdx = strfind(obj.directory,'+');
                for i=length(pkgIdx):-1:1
                    pre = [moddir(pkgIdx(i)+1:end) '.' pre];
                    moddir = moddir(1:pkgIdx(i)-2);
                end
                % if package is on root directory...
                if isempty(strfind(obj.directory,'/')) && isempty(strfind(obj.directory,'\'))
                    moddir = obj.directory;
                end
            end

            % change to appropriate directory
            % cd(moddir); % gives me sometimes an error.
            cd(wh.path);
            % save the fullpath to the class / directory
            obj.fullpath = wh.path;
        end
        
        %% FIND classes in directory
        function find_classes_in_dir(obj, wh, pre, dir0)

            % check for classes in the directory, add to metalist
            if ~isempty(wh.m)
                for i=1:length(wh.m)
                    % default way
                    obj.metalist{i} = meta.class.fromName([pre wh.m{i}(1:end-2)]);
                    % the directory itself might be a class
                    if ~isempty(pre)
                        dir_idx = findstr(pre, '@');
                        dir_name = pre(dir_idx+1:end-1);
                        if strcmp(dir_name, wh.m{i}(1:end-2))
                            package_name = pre(1:dir_idx-2);
                            obj.metalist{i} = meta.class.fromName([package_name '.' dir_name]);
                        end
                    end
                end
                % remove any empty metaclass entries (generated from non-class
                % m-files)
                obj.metalist(cellfun(@isempty, obj.metalist)) = [];
            end

            % check for classes in @ folders, add to metalist
            if ~isempty(wh.classes)
                classes = cell(1,length(wh.classes));
                for i=1:length(wh.classes)
                    classes{i} = meta.class.fromName([pre wh.classes{i}]);
                end
                obj.metalist = [obj.metalist classes];
            end

            % check for classes in packages, add to metalist
            if ~isempty(wh.packages)
                pkgClasses = {};
                for i=1:length(wh.packages)
                    pkgClasses = [pkgClasses classInheritance.iTree.getPkgClasses([pre wh.packages{i}])];
                end
                obj.metalist = [obj.metalist pkgClasses];
            end

            % check that classes have been found, or die
            if isempty(obj.metalist)
                cd(dir0);
                error('classInheritance:iTreeClassNOTFOUND', 'Error: No classes found.');
            end
        end
        
        %% find all class information and fill the metalist property
        function fill_metalist(obj, dir0)
            
            % if you press the 'Go' button many times (without changing the
            % directory), then some of the metalist entries will be
            % 'deleted'. I don't know why, but let's check for this here:
            % kick out delete classes in metalist
            for i=1:length(obj.metalist)
                if ~isvalid(obj.metalist{i})
                    obj.metalist{i} = [];
                end
            end
            obj.metalist(cellfun(@isempty, obj.metalist)) = [];

            % check for superclasses, add to metalist if not duplicates
            superclassnames = {};
            allsupclasses = cell(1,length(obj.metalist));
            for i=1:length(obj.metalist)
                if ~isempty(obj.metalist{i}.SuperClasses)
                    allsupclasses{i} = [allsupclasses{i} classInheritance.iTree.superSearch(obj.metalist{i}.SuperClasses)];
                    superclassnames = [superclassnames classInheritance.iTree.superSearch(obj.metalist{i}.SuperClasses)];
                end
            end
            superclassnames = unique(superclassnames);
            if ~isempty(superclassnames)
                superclasses = cell(1,length(superclassnames));
                for i=1:length(superclassnames)
                    if ~obj.isduplicate(superclassnames{i})
                        superclasses{i} = meta.class.fromName(superclassnames{i});
                    end
                end
                superclasses(cellfun(@isempty,superclasses)) = [];
                obj.metalist = [obj.metalist superclasses];
            end

            % intiate Tree objects, mapping one-to-one from metalist
            obj.treelist = cell(1,length(obj.metalist));
            for i=1:length(obj.metalist)
                treename = classInheritance.iTree.format(obj.metalist{i}.Name);
                obj.treelist{i} = classInheritance.Tree(treename);
            end

            % link Tree objects together according to inheritance hierarchy.
            for i=1:length(obj.metalist)
                if isempty(obj.metalist{i}.SuperClasses)
                    obj.rootIdx = [obj.rootIdx i]; % assign rootIdx
                else
                    for j=1:length(obj.metalist{i}.SuperClasses)
                        for k=1:length(obj.metalist)
                            if strcmp(obj.metalist{i}.SuperClasses{j}.Name,obj.metalist{k}.Name)
                                obj.treelist{k}.addChild(obj.treelist{i});
                            end
                        end
                    end
                end
            end

            % convert meta.class objects in metalist to structures with desired data, so that
            % they don't get deleted upon any directory change
            s = cell(1,length(obj.metalist));
            for i=1:length(obj.metalist)

                s{i}.Name = classInheritance.iTree.format(obj.metalist{i}.Name);

                %% PROPERTIES
                
                % DO NOT use a for-loop to read out the properties 
                % information - this is will take very long for classes 
                % that contain many properties
                
                % ideally, we want to read out the help text for each
                % property here once and save it. Unfortunately, 'help' is
                % very SLOW (for 300 properties it takes ~8 seconds).
                
                % faster implementation
                Names = cellfun(@(x) obj.format(x.Name), obj.metalist{i}.Properties, 'UniformOutput', false);
                DefiningClasses = cellfun(@(x) obj.format(x.DefiningClass.Name), obj.metalist{i}.Properties, 'UniformOutput', false);
                GetAccess = cellfun(@(x) obj.format(x.GetAccess), obj.metalist{i}.Properties, 'UniformOutput', false);
                SetAccess = cellfun(@(x) obj.format(x.SetAccess), obj.metalist{i}.Properties, 'UniformOutput', false);

                % preallocate cell of structs
                % don't use DefiningClass.Name - this is slow.
                s{i}.Properties = repmat({struct('Name', [], 'DefiningClassName', [], 'GetAccess', [], 'SetAccess', [])}, 1, length(obj.metalist{i}.Properties));
                for j=1:length(obj.metalist{i}.Properties)
                    s{i}.Properties{j}.Name = Names{j};
                    s{i}.Properties{j}.DefiningClassName = DefiningClasses{j};
                    s{i}.Properties{j}.GetAccess = GetAccess{j};
                    s{i}.Properties{j}.SetAccess = SetAccess{j};
                end

                % sort properties by name
                s{i}.Properties = obj.sort_cell(s{i}.Properties, obj.metalist{i}.Properties);

                %% METHODS
                % do not use a for-loop here, cellfun is way faster.
                Names = cellfun(@(x) obj.format(x.Name), obj.metalist{i}.Methods, 'UniformOutput', false);
                DefiningClasses = cellfun(@(x) obj.format(x.DefiningClass.Name), obj.metalist{i}.Methods, 'UniformOutput', false);
                Access = cellfun(@(x) obj.format(x.Access), obj.metalist{i}.Methods, 'UniformOutput', false);
                Abstract = cellfun(@(x) obj.format(x.Abstract), obj.metalist{i}.Methods, 'UniformOutput', false);
                Sealed = cellfun(@(x) obj.format(x.Sealed), obj.metalist{i}.Methods, 'UniformOutput', false);
                Hidden = cellfun(@(x) obj.format(x.Hidden), obj.metalist{i}.Methods, 'UniformOutput', false);

                % preallocate cell of structs
                % don't use DefiningClass.Name - this is slow.
                s{i}.Methods = repmat({struct('Name', [], 'DefiningClassName', [], 'Access', [], 'Abstract', [], 'Sealed', [], 'Hidden', [])}, 1, length(obj.metalist{i}.Methods));
                for j=1:length(obj.metalist{i}.Methods)
                    s{i}.Methods{j}.Name = Names{j};
                    s{i}.Methods{j}.DefiningClassName = DefiningClasses{j};
                    s{i}.Methods{j}.Access = Access{j};
                    s{i}.Methods{j}.Abstract = Abstract{j};
                    s{i}.Methods{j}.Sealed = Sealed{j};
                    s{i}.Methods{j}.Hidden = Hidden{j};
                end

                % sort methods by name
                s{i}.Methods = obj.sort_cell(s{i}.Methods, obj.metalist{i}.Methods);

                %% SUPERCLASSES
                if i<length(allsupclasses)
                    s{i}.SuperClasses = cell(1,length(allsupclasses{i}));
                    for j=1:length(allsupclasses{i})
                        s{i}.SuperClasses{j}.Name = classInheritance.iTree.format(allsupclasses{i}{j});
                    end
                    s{i}.InferiorClasses = cell(1,length(obj.metalist{i}.InferiorClasses));
                else
                    s{i}.SuperClasses = cell(1,length(obj.metalist{i}.SuperClasses));
                    for j=1:length(obj.metalist{i}.SuperClasses)
                        s{i}.SuperClasses{j}.Name = classInheritance.iTree.format(obj.metalist{i}.SuperClasses{j}.Name);
                    end
                end
                for j=1:length(obj.metalist{i}.InferiorClasses)
                    s{i}.InferiorClasses{j}.Name = classInheritance.iTree.format(obj.metalist{i}.InferiorClasses{j}.Name);
                end
            end
            obj.metalist = s;
            cd(dir0); % change back to original directory
        end
        
        %% display the class inheritance diagram
        function view(obj)
            treeRoots = obj.treelist(obj.rootIdx);
            nodeList = {};
            k = 1;
            for currentRootIdx = 1:length(treeRoots)
                T = treeRoots{currentRootIdx};
                nodeList{k} = T;
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
                k = k + 1;
            end
            numNodes = length(nodeList);
            if (numNodes == 1)
                CN = 1;
                ID = nodeList{1}.myInfo;
                if ischar(ID)
                    ID = {ID};
                end                
            else
                CN = zeros(numNodes);
                ID = cell(1,numNodes);
                s = struct;
                for i = 1:numNodes
                    nodeName = nodeList{i}.myInfo;
                    s.(nodeName) = i;
                end
                for i = 1:numNodes
                    currentNode = nodeList{i};
                    ID{i} = currentNode.myInfo;
                    for x = 1:length(currentNode.myChildren)
                        currentChild = currentNode.myChildren{x};
                        CN(i,s.(currentChild.myInfo)) = 1;
                    end
                end
            end
            for i=1:length(ID)
                if ~isempty(strfind(ID{i},'DOT'))
                    ID{i} = strrep(ID{i},'DOT','.');
                end
            end
            
            % the call to 'biograph' might fail since the API might change.
            try
                bgobj = biograph(CN,ID);
                set(0,'ShowHiddenHandles','on')
                obj.h = view(bgobj);
                obj.fighan = gcf;
                set(0,'ShowHiddenHandles','off')
            catch %#ok<CTCH>
            end
        end
        
        %%
        function display(obj)
            display(['Class inheritance tree diagram for directory ''' obj.directory ''''])
            display('Use ''view'' to display the inheritance tree')
        end
        
        %%
        function close(obj)
            close(obj.fighan)
        end
        
        %%
        function status = view_running(obj)
        % is the GUI still open?
            status = 0;
            if ishandle(obj.fighan)
                status = 1;
            end
        end
    end
    
    %% PROTECTED methods
    methods (Access = protected)
        % utility; returns true if the classname passed is present in metalist
        function bool = isduplicate(obj,classname)
            bool = false;
            for i=1:length(obj.metalist)
                if strcmp(classname,obj.metalist{i}.Name)
                    bool = true;
                    break
                end
            end
        end
    end    
    
    %% STATIC methods, for this class only
    methods (Static = true, Access = protected)
        
        % recursive fucntion generating a list of names of all superior
        % classes encountered when following branches upwards from a class.
        function out = superSearch(metaobj)
            out = cell(1,length(metaobj));
            for i=1:length(metaobj);
                out{i} = metaobj{i}.Name;
                if ~isempty(metaobj{i}.SuperClasses)
                    out = [out classInheritance.iTree.superSearch(metaobj{i}.SuperClasses)];
                end
            end
        end
        
        % recursive function generating a list of meta.class objects
        % representing all classes contained in scoped packages
        function pkgClasses = getPkgClasses(pkgName)
            metaPkg = meta.package.fromName(pkgName);
            pkgClasses = rot90(metaPkg.Classes);
            if ~isempty(metaPkg.Packages)
                for i=1:length(metaPkg.Packages)
                    pkgClasses = [pkgClasses classInheritance.iTree.getPkgClasses(metaPkg.Packages{i}.Name)];
                end
            end
        end
        
        function cellarray = sort_cell(cellarray, sort_by)
            % sorts cellarray by name
            [sorted_names, sorted_indices] = sort(cellfun(@(x) x.Name, sort_by, 'UniformOutput', false)); %#ok<ASGLU>
            cellarray = cellarray(sorted_indices);
        end
    end
    
    %% STATIC methods
    methods (Static = true)
        % format packagename.classname -> packagenameDOTclassname
        function fstr = format(str)
            if ~isempty(strfind(str,'.'))
                fstr = strrep(str,'.','DOT');
            else
                fstr = str;
            end
        end
        
        % unformat packagenameDOTclassname -> packagename.classname
        function fstr = unformat(str)
            if ~isempty(strfind(str, 'DOT'))
                fstr = strrep(str, 'DOT', '.');
            else
                fstr = str;
            end
        end
        
    end
    
end

% Class Inheritance Browser Copyright Clayton Ernst, Andrew Hagen, Eric Lee and Andreas Kotowicz 2012. 
