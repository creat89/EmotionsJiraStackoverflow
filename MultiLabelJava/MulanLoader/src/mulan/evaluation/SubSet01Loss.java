package mulan.evaluation;

import mulan.evaluation.measure.ExampleBasedBipartitionMeasureBase;

public class SubSet01Loss extends ExampleBasedBipartitionMeasureBase {
	@Override
    public String getName() {
        return "Subset 01 Loss";
    }

    @Override
    public double getIdealValue() {
        return 0;
    }

    @Override
    protected void updateBipartition(boolean[] bipartition, boolean[] truth) {
        double value = 0;
        for (int i = 0; i < truth.length; i++) {
            if (bipartition[i] != truth[i]) {
                value = 1;
                break;
            }
        }

        sum += value;
        count++;
    }
}
