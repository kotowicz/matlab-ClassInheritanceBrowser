function extractHelpText(inputFullPath, outputDir)
    [~, fileName] = fileparts(inputFullPath);

    if ~exist(inputFullPath, 'file')
        error(message('MATLAB:extractHelpText:FileNotFound'));
    end

    outputFile = fullfile(outputDir, [fileName '.m']);
    if isequal(outputFile, inputFullPath)
        error(message('MATLAB:classInheritance.helpUtils.extractHelpText:SameFile'));
    end

    if exist(outputFile, 'file')
        s = warning('off', 'MATLAB:DELETE:Permission');
        cleanup = onCleanup(@()warning(s));
        delete(outputFile);
        if exist(outputFile, 'file')
            error(message('MATLAB:classInheritance.helpUtils.extractHelpText:CannotDeleteFile'));            
        end
    end

    helpContainer = classInheritance.helpUtils.containers.HelpContainerFactory.create(inputFullPath, 'onlyLocalHelp', true);
    helpContainer.exportToMFile(outputDir);
end

