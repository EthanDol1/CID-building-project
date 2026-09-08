function syncEditor()
%SYNCEDITOR Reload every open Editor document from disk.
%   Discards unsaved buffer changes in favour of the file on disk.
docs = matlab.desktop.editor.getAll;
arrayfun(@reload, docs);
fprintf('Reloaded %d open file(s).\n', numel(docs));
end