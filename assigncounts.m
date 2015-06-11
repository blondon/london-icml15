function examples = assigncounts(examples, nodeCount, edgeCount)

for i = 1:size(examples,1)
	for j = 1:size(examples,2)
		examples{i,j}.edgeStruct.nodeCount = nodeCount;
		examples{i,j}.edgeStruct.edgeCount = edgeCount;		
	end
end