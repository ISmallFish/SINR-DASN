# **SINR-DASN**

## Data Preparation

- ### Cat Librispeech

The _train-clean-100_, _train-clean-360_, _dev-clean_, and _test-clean_ datasets in LibriSpeech, which contain speech from the same speakers, are concatenated, resulting in a total of 1252 utterances (251, 921, 40, and 40, respectively).

- ### Gen Room Impulse Response

1. The RIRs for the _Training Data_ and _Development Data_ are generated using `genRIR_ForFrmLvSINR_TrainingData`.

# Updated on November 18, 2024

The code and datasets are currently under preparation, with the release scheduled no later than December 20.

(The original plan was to release it before November 20, but I’ve been too busy recently. I sincerely apologize.)

# Ref.
- > S. Guan, M. Wang, Z. Bai, J. Wang, J. Chen and J. Benesty, "Smoothed Frame-Level SINR and Its Estimation for Sensor Selection in Distributed Acoustic Sensor Networks," in IEEE/ACM Transactions on Audio, Speech, and Language Processing, doi: 10.1109/TASLP.2024.3477277.
- > Pan, Chao, et al. "An Anchor-Point Based Image-Model for Room Impulse Response Simulation with Directional Source Radiation and Sensor Directivity Patterns." arXiv preprint arXiv:2308.10543 (2023).
