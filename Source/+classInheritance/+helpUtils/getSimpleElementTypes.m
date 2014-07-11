function elementTypes = getSimpleElementTypes
    elementTypes = struct(...
        'keyword', {'properties', 'events', 'enumeration'}, ...
        'list', {'PropertyList', 'EventList', 'EnumerationMemberList'}, ...
        'node',  {'property-info', 'event-info', 'enumeration-info'});
end
