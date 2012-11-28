function numbers = enumText(text)
numSamples = size(text,1);
map = containers.Map();
value = 0;
numbers = zeros(numSamples,1);
for i = 1:numSamples
    if ~map.isKey(char(text(i)))
        value = value + 1;
        map(char(text(i))) = value;
    end
    numbers(i) = map(char(text(i)));
end